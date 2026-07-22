Set-StrictMode -Version Latest

$script:BppDefaultMemoryLimitBytes = [UInt64]4294967296

if (-not ([System.Management.Automation.PSTypeName]'Bpp.Windows.JobMemoryLimiter').Type) {
    Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;

namespace Bpp.Windows
{
    public static class JobMemoryLimiter
    {
        private const UInt32 JOB_OBJECT_LIMIT_PROCESS_MEMORY = 0x00000100;
        private const UInt32 JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x00002000;
        private const Int32 JobObjectExtendedLimitInformation = 9;

        [StructLayout(LayoutKind.Sequential)]
        private struct JOBOBJECT_BASIC_LIMIT_INFORMATION
        {
            public Int64 PerProcessUserTimeLimit;
            public Int64 PerJobUserTimeLimit;
            public UInt32 LimitFlags;
            public UIntPtr MinimumWorkingSetSize;
            public UIntPtr MaximumWorkingSetSize;
            public UInt32 ActiveProcessLimit;
            public UIntPtr Affinity;
            public UInt32 PriorityClass;
            public UInt32 SchedulingClass;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct IO_COUNTERS
        {
            public UInt64 ReadOperationCount;
            public UInt64 WriteOperationCount;
            public UInt64 OtherOperationCount;
            public UInt64 ReadTransferCount;
            public UInt64 WriteTransferCount;
            public UInt64 OtherTransferCount;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct JOBOBJECT_EXTENDED_LIMIT_INFORMATION
        {
            public JOBOBJECT_BASIC_LIMIT_INFORMATION BasicLimitInformation;
            public IO_COUNTERS IoInfo;
            public UIntPtr ProcessMemoryLimit;
            public UIntPtr JobMemoryLimit;
            public UIntPtr PeakProcessMemoryUsed;
            public UIntPtr PeakJobMemoryUsed;
        }

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern IntPtr CreateJobObject(IntPtr jobAttributes, string name);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool SetInformationJobObject(
            IntPtr job,
            Int32 infoClass,
            ref JOBOBJECT_EXTENDED_LIMIT_INFORMATION info,
            UInt32 infoLength);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool AssignProcessToJobObject(IntPtr job, IntPtr process);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool TerminateJobObject(IntPtr job, UInt32 exitCode);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool CloseHandle(IntPtr handle);

        public static IntPtr Create(UInt64 processMemoryLimitBytes)
        {
            IntPtr job = CreateJobObject(IntPtr.Zero, null);
            if (job == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateJobObject failed");
            }

            JOBOBJECT_EXTENDED_LIMIT_INFORMATION info = new JOBOBJECT_EXTENDED_LIMIT_INFORMATION();
            info.BasicLimitInformation.LimitFlags =
                JOB_OBJECT_LIMIT_PROCESS_MEMORY | JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
            info.ProcessMemoryLimit = new UIntPtr(processMemoryLimitBytes);
            UInt32 size = (UInt32)Marshal.SizeOf(typeof(JOBOBJECT_EXTENDED_LIMIT_INFORMATION));

            if (!SetInformationJobObject(job, JobObjectExtendedLimitInformation, ref info, size))
            {
                Int32 error = Marshal.GetLastWin32Error();
                CloseHandle(job);
                throw new Win32Exception(error, "SetInformationJobObject failed");
            }
            return job;
        }

        public static void Assign(IntPtr job, IntPtr process)
        {
            if (!AssignProcessToJobObject(job, process))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "AssignProcessToJobObject failed");
            }
        }

        public static void Terminate(IntPtr job, UInt32 exitCode)
        {
            if (job != IntPtr.Zero && !TerminateJobObject(job, exitCode))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "TerminateJobObject failed");
            }
        }

        public static void Close(IntPtr job)
        {
            if (job != IntPtr.Zero)
            {
                CloseHandle(job);
            }
        }
    }
}
'@
}

function ConvertTo-BppNativeArgument {
    param([AllowEmptyString()][string]$Value)

    if ($Value -eq "") { return '""' }
    if ($Value -notmatch '[\s"]') { return $Value }

    $builder = New-Object System.Text.StringBuilder
    [void]$builder.Append('"')
    $backslashes = 0
    foreach ($char in $Value.ToCharArray()) {
        if ($char -eq '\') {
            $backslashes += 1
            continue
        }
        if ($char -eq '"') {
            [void]$builder.Append(('\' * (($backslashes * 2) + 1)))
            [void]$builder.Append('"')
            $backslashes = 0
            continue
        }
        if ($backslashes -gt 0) {
            [void]$builder.Append(('\' * $backslashes))
            $backslashes = 0
        }
        [void]$builder.Append($char)
    }
    if ($backslashes -gt 0) {
        [void]$builder.Append(('\' * ($backslashes * 2)))
    }
    [void]$builder.Append('"')
    return $builder.ToString()
}

function Invoke-BppLimitedProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [string[]]$ArgumentList = @(),
        [int]$TimeoutMs = 0,
        [AllowEmptyString()][string]$StdinText = "",
        [string]$StdoutPath = "",
        [string]$StderrPath = "",
        [string]$WorkingDirectory = "",
        [UInt64]$MemoryLimitBytes = $script:BppDefaultMemoryLimitBytes
    )

    $resolvedFile = if (Test-Path -LiteralPath $FilePath) {
        (Resolve-Path -LiteralPath $FilePath).Path
    } else {
        $command = Get-Command $FilePath -ErrorAction SilentlyContinue
        if (-not $command) { throw "Process executable not found: $FilePath" }
        $command.Source
    }

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $resolvedFile
    $psi.Arguments = (($ArgumentList | ForEach-Object { ConvertTo-BppNativeArgument -Value ([string]$_) }) -join ' ')
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardInput = $true
    $psi.CreateNoWindow = $true
    if ($WorkingDirectory) { $psi.WorkingDirectory = $WorkingDirectory }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $psi.StandardOutputEncoding = $utf8NoBom
    $psi.StandardErrorEncoding = $utf8NoBom

    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $psi
    $job = [IntPtr]::Zero
    $timedOut = $false

    try {
        $job = [Bpp.Windows.JobMemoryLimiter]::Create($MemoryLimitBytes)
        if (-not $process.Start()) { throw "Failed to start process: $resolvedFile" }
        try {
            [Bpp.Windows.JobMemoryLimiter]::Assign($job, $process.Handle)
        } catch {
            try { $process.Kill() } catch { }
            throw
        }

        if ($StdinText -ne "") { $process.StandardInput.Write($StdinText) }
        $process.StandardInput.Close()

        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()

        if ($TimeoutMs -gt 0) {
            $exited = $process.WaitForExit($TimeoutMs)
            if (-not $exited) {
                $timedOut = $true
                [Bpp.Windows.JobMemoryLimiter]::Terminate($job, 124)
                [void]$process.WaitForExit(5000)
            }
        } else {
            $process.WaitForExit()
        }

        $stdout = $stdoutTask.Result
        $stderr = $stderrTask.Result
        $exitCode = if ($timedOut) { 124 } else { $process.ExitCode }

        if ($StdoutPath) { [System.IO.File]::WriteAllText($StdoutPath, $stdout, $utf8NoBom) }
        if ($StderrPath) { [System.IO.File]::WriteAllText($StderrPath, $stderr, $utf8NoBom) }

        return [PSCustomObject]@{
            ExitCode = $exitCode
            Stdout = $stdout
            Stderr = $stderr
            TimedOut = $timedOut
        }
    } finally {
        if ($job -ne [IntPtr]::Zero) { [Bpp.Windows.JobMemoryLimiter]::Close($job) }
        $process.Dispose()
    }
}
