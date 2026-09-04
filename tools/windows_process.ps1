Set-StrictMode -Version Latest

$script:BppDefaultMemoryLimitBytes = [UInt64]4294967296

if (-not ([System.Management.Automation.PSTypeName]'Bpp.Windows.JobMemoryLimiter').Type) {
    Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Diagnostics;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;
using Microsoft.Win32.SafeHandles;

namespace Bpp.Windows
{
    public sealed class StreamPump
    {
        private readonly Stream source;
        private readonly Stream destination;
        private readonly Thread thread;
        private Exception error;

        internal StreamPump(Stream source, Stream destination)
        {
            this.source = source;
            this.destination = destination;
            this.thread = new Thread(Copy);
            this.thread.IsBackground = true;
            this.thread.Name = "Bpp process stream pump";
        }

        private void Copy()
        {
            try
            {
                source.CopyTo(destination, 65536);
            }
            catch (Exception ex)
            {
                error = ex;
            }
        }

        internal void Start()
        {
            thread.Start();
        }

        public void Wait()
        {
            thread.Join();
            if (error != null)
            {
                throw new IOException("Process stream copy failed", error);
            }
        }
    }

    public sealed class StartedProcess : IDisposable
    {
        public Process Process { get; private set; }
        public FileStream StandardInput { get; private set; }
        public FileStream StandardOutput { get; private set; }
        public FileStream StandardError { get; private set; }
        public IntPtr ProcessHandle { get; private set; }

        internal StartedProcess(Process process, IntPtr processHandle, IntPtr stdinWrite, IntPtr stdoutRead, IntPtr stderrRead)
        {
            Process = process;
            ProcessHandle = processHandle;
            StandardInput = new FileStream(new SafeFileHandle(stdinWrite, true), FileAccess.Write, 4096, false);
            StandardOutput = new FileStream(new SafeFileHandle(stdoutRead, true), FileAccess.Read, 4096, false);
            StandardError = new FileStream(new SafeFileHandle(stderrRead, true), FileAccess.Read, 4096, false);
        }

        public void Dispose()
        {
            StandardInput.Dispose();
            StandardOutput.Dispose();
            StandardError.Dispose();
            Process.Dispose();
            JobMemoryLimiter.Close(ProcessHandle);
            ProcessHandle = IntPtr.Zero;
        }
    }

    public static class JobMemoryLimiter
    {
        private const UInt32 JOB_OBJECT_LIMIT_PROCESS_MEMORY = 0x00000100;
        private const UInt32 JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION = 0x00000400;
        private const UInt32 JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x00002000;
        private const Int32 JobObjectExtendedLimitInformation = 9;
        private const UInt32 STARTF_USESTDHANDLES = 0x00000100;
        private const UInt32 CREATE_SUSPENDED = 0x00000004;
        private const UInt32 CREATE_NO_WINDOW = 0x08000000;
        private const UInt32 HANDLE_FLAG_INHERIT = 0x00000001;
        private const UInt32 SEM_FAILCRITICALERRORS = 0x0001;
        private const UInt32 SEM_NOGPFAULTERRORBOX = 0x0002;
        private static readonly Object ProcessCreationLock = new Object();

        [StructLayout(LayoutKind.Sequential)]
        private struct SECURITY_ATTRIBUTES
        {
            public Int32 nLength;
            public IntPtr lpSecurityDescriptor;
            [MarshalAs(UnmanagedType.Bool)] public bool bInheritHandle;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct STARTUPINFO
        {
            public Int32 cb;
            public string lpReserved;
            public string lpDesktop;
            public string lpTitle;
            public UInt32 dwX;
            public UInt32 dwY;
            public UInt32 dwXSize;
            public UInt32 dwYSize;
            public UInt32 dwXCountChars;
            public UInt32 dwYCountChars;
            public UInt32 dwFillAttribute;
            public UInt32 dwFlags;
            public UInt16 wShowWindow;
            public UInt16 cbReserved2;
            public IntPtr lpReserved2;
            public IntPtr hStdInput;
            public IntPtr hStdOutput;
            public IntPtr hStdError;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct PROCESS_INFORMATION
        {
            public IntPtr hProcess;
            public IntPtr hThread;
            public UInt32 dwProcessId;
            public UInt32 dwThreadId;
        }

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
        private static extern bool QueryInformationJobObject(
            IntPtr job,
            Int32 infoClass,
            out JOBOBJECT_EXTENDED_LIMIT_INFORMATION info,
            UInt32 infoLength,
            IntPtr returnLength);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool TerminateJobObject(IntPtr job, UInt32 exitCode);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool CloseHandle(IntPtr handle);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool CreatePipe(
            out IntPtr readPipe,
            out IntPtr writePipe,
            ref SECURITY_ATTRIBUTES pipeAttributes,
            UInt32 size);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool SetHandleInformation(IntPtr handle, UInt32 mask, UInt32 flags);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool CreateProcess(
            string applicationName,
            StringBuilder commandLine,
            IntPtr processAttributes,
            IntPtr threadAttributes,
            bool inheritHandles,
            UInt32 creationFlags,
            IntPtr environment,
            string currentDirectory,
            ref STARTUPINFO startupInfo,
            out PROCESS_INFORMATION processInformation);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern UInt32 ResumeThread(IntPtr thread);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool TerminateProcess(IntPtr process, UInt32 exitCode);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool GetExitCodeProcess(IntPtr process, out UInt32 exitCode);

        [DllImport("kernel32.dll")]
        private static extern UInt32 SetErrorMode(UInt32 mode);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool GetProcessTimes(
            IntPtr process,
            out Int64 creationTime,
            out Int64 exitTime,
            out Int64 kernelTime,
            out Int64 userTime);

        public static IntPtr Create(UInt64 processMemoryLimitBytes)
        {
            IntPtr job = CreateJobObject(IntPtr.Zero, null);
            if (job == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateJobObject failed");
            }

            JOBOBJECT_EXTENDED_LIMIT_INFORMATION info = new JOBOBJECT_EXTENDED_LIMIT_INFORMATION();
            info.BasicLimitInformation.LimitFlags =
                JOB_OBJECT_LIMIT_PROCESS_MEMORY |
                JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION |
                JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
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

        public static UInt64 PeakProcessMemoryUsed(IntPtr job)
        {
            JOBOBJECT_EXTENDED_LIMIT_INFORMATION info;
            UInt32 size = (UInt32)Marshal.SizeOf(typeof(JOBOBJECT_EXTENDED_LIMIT_INFORMATION));
            if (!QueryInformationJobObject(
                job,
                JobObjectExtendedLimitInformation,
                out info,
                size,
                IntPtr.Zero))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "QueryInformationJobObject failed");
            }
            return info.PeakProcessMemoryUsed.ToUInt64();
        }

        public static Double CpuTimeMilliseconds(IntPtr process)
        {
            Int64 creationTime, exitTime, kernelTime, userTime;
            if (!GetProcessTimes(process, out creationTime, out exitTime, out kernelTime, out userTime))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "GetProcessTimes failed");
            }
            return (kernelTime + userTime) / 10000.0;
        }

        public static StreamPump StartPump(Stream source, Stream destination)
        {
            StreamPump pump = new StreamPump(source, destination);
            pump.Start();
            return pump;
        }

        public static StartedProcess StartProcess(
            IntPtr job,
            string applicationName,
            string commandLine,
            string workingDirectory)
        {
            // CreateProcess with bInheritHandles=true inherits every inheritable
            // handle in this PowerShell host. Serialize the short create/close
            // window so parallel runspaces cannot inherit each other's pipe ends.
            lock (ProcessCreationLock)
            {
                return StartProcessLocked(job, applicationName, commandLine, workingDirectory);
            }
        }

        private static StartedProcess StartProcessLocked(
            IntPtr job,
            string applicationName,
            string commandLine,
            string workingDirectory)
        {
            SECURITY_ATTRIBUTES attributes = new SECURITY_ATTRIBUTES();
            attributes.nLength = Marshal.SizeOf(typeof(SECURITY_ATTRIBUTES));
            attributes.bInheritHandle = true;

            IntPtr stdinRead = IntPtr.Zero, stdinWrite = IntPtr.Zero;
            IntPtr stdoutRead = IntPtr.Zero, stdoutWrite = IntPtr.Zero;
            IntPtr stderrRead = IntPtr.Zero, stderrWrite = IntPtr.Zero;
            PROCESS_INFORMATION processInfo = new PROCESS_INFORMATION();
            bool started = false;

            try
            {
                CreateParentPipe(ref attributes, out stdinRead, out stdinWrite, false);
                CreateParentPipe(ref attributes, out stdoutRead, out stdoutWrite, true);
                CreateParentPipe(ref attributes, out stderrRead, out stderrWrite, true);

                STARTUPINFO startupInfo = new STARTUPINFO();
                startupInfo.cb = Marshal.SizeOf(typeof(STARTUPINFO));
                startupInfo.dwFlags = STARTF_USESTDHANDLES;
                startupInfo.hStdInput = stdinRead;
                startupInfo.hStdOutput = stdoutWrite;
                startupInfo.hStdError = stderrWrite;

                StringBuilder mutableCommandLine = new StringBuilder(commandLine);
                UInt32 previousErrorMode = SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOGPFAULTERRORBOX);
                bool created;
                Int32 createError = 0;
                try
                {
                    created = CreateProcess(
                        applicationName,
                        mutableCommandLine,
                        IntPtr.Zero,
                        IntPtr.Zero,
                        true,
                        CREATE_SUSPENDED | CREATE_NO_WINDOW,
                        IntPtr.Zero,
                        String.IsNullOrEmpty(workingDirectory) ? null : workingDirectory,
                        ref startupInfo,
                        out processInfo);
                    if (!created) { createError = Marshal.GetLastWin32Error(); }
                }
                finally
                {
                    SetErrorMode(previousErrorMode);
                }
                if (!created)
                {
                    throw new Win32Exception(createError, "CreateProcess failed");
                }
                started = true;
                Assign(job, processInfo.hProcess);

                Process process = Process.GetProcessById((Int32)processInfo.dwProcessId);
                if (ResumeThread(processInfo.hThread) == UInt32.MaxValue)
                {
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "ResumeThread failed");
                }

                CloseHandle(stdinRead); stdinRead = IntPtr.Zero;
                CloseHandle(stdoutWrite); stdoutWrite = IntPtr.Zero;
                CloseHandle(stderrWrite); stderrWrite = IntPtr.Zero;
                CloseHandle(processInfo.hThread); processInfo.hThread = IntPtr.Zero;
                StartedProcess result = new StartedProcess(
                    process,
                    processInfo.hProcess,
                    stdinWrite,
                    stdoutRead,
                    stderrRead);
                processInfo.hProcess = IntPtr.Zero;
                stdinWrite = IntPtr.Zero;
                stdoutRead = IntPtr.Zero;
                stderrRead = IntPtr.Zero;
                return result;
            }
            catch
            {
                if (started && processInfo.hProcess != IntPtr.Zero)
                {
                    TerminateProcess(processInfo.hProcess, 1);
                }
                throw;
            }
            finally
            {
                CloseIfValid(stdinRead); CloseIfValid(stdinWrite);
                CloseIfValid(stdoutRead); CloseIfValid(stdoutWrite);
                CloseIfValid(stderrRead); CloseIfValid(stderrWrite);
                CloseIfValid(processInfo.hThread); CloseIfValid(processInfo.hProcess);
            }
        }

        private static void CreateParentPipe(
            ref SECURITY_ATTRIBUTES attributes,
            out IntPtr readPipe,
            out IntPtr writePipe,
            bool parentReads)
        {
            if (!CreatePipe(out readPipe, out writePipe, ref attributes, 0))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "CreatePipe failed");
            }
            IntPtr parentHandle = parentReads ? readPipe : writePipe;
            if (!SetHandleInformation(parentHandle, HANDLE_FLAG_INHERIT, 0))
            {
                Int32 error = Marshal.GetLastWin32Error();
                CloseHandle(readPipe);
                CloseHandle(writePipe);
                readPipe = IntPtr.Zero;
                writePipe = IntPtr.Zero;
                throw new Win32Exception(error, "SetHandleInformation failed");
            }
        }

        private static void CloseIfValid(IntPtr handle)
        {
            if (handle != IntPtr.Zero && handle != new IntPtr(-1))
            {
                CloseHandle(handle);
            }
        }

        public static void Close(IntPtr job)
        {
            if (job != IntPtr.Zero)
            {
                CloseHandle(job);
            }
        }

        public static Int32 ExitCode(IntPtr process)
        {
            UInt32 exitCode;
            if (!GetExitCodeProcess(process, out exitCode))
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "GetExitCodeProcess failed");
            }
            return unchecked((Int32)exitCode);
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

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $nativeArgs = (($ArgumentList | ForEach-Object { ConvertTo-BppNativeArgument -Value ([string]$_) }) -join ' ')
    $nativeCommandLine = (ConvertTo-BppNativeArgument -Value $resolvedFile)
    if ($nativeArgs) { $nativeCommandLine += " $nativeArgs" }

    $startedProcess = $null
    $process = $null
    $job = [IntPtr]::Zero
    $timedOut = $false
    $stdoutFile = $null
    $stderrFile = $null
    $stdoutBuffer = $null
    $stderrBuffer = $null
    $stdoutPump = $null
    $stderrPump = $null
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        $job = [Bpp.Windows.JobMemoryLimiter]::Create($MemoryLimitBytes)
        $startedProcess = [Bpp.Windows.JobMemoryLimiter]::StartProcess(
            $job,
            $resolvedFile,
            $nativeCommandLine,
            $WorkingDirectory
        )
        $process = $startedProcess.Process

        if ($StdinText -ne "") {
            $stdinBytes = $utf8NoBom.GetBytes($StdinText)
            $startedProcess.StandardInput.Write($stdinBytes, 0, $stdinBytes.Length)
            $startedProcess.StandardInput.Flush()
        }
        $startedProcess.StandardInput.Close()

        if ($StdoutPath) {
            $stdoutFile = New-Object System.IO.FileStream(
                $StdoutPath,
                [System.IO.FileMode]::Create,
                [System.IO.FileAccess]::Write,
                [System.IO.FileShare]::Read
            )
            $stdoutPump = [Bpp.Windows.JobMemoryLimiter]::StartPump($startedProcess.StandardOutput, $stdoutFile)
        } else {
            $stdoutBuffer = New-Object System.IO.MemoryStream
            $stdoutPump = [Bpp.Windows.JobMemoryLimiter]::StartPump($startedProcess.StandardOutput, $stdoutBuffer)
        }
        if ($StderrPath) {
            $stderrFile = New-Object System.IO.FileStream(
                $StderrPath,
                [System.IO.FileMode]::Create,
                [System.IO.FileAccess]::Write,
                [System.IO.FileShare]::Read
            )
            $stderrPump = [Bpp.Windows.JobMemoryLimiter]::StartPump($startedProcess.StandardError, $stderrFile)
        } else {
            $stderrBuffer = New-Object System.IO.MemoryStream
            $stderrPump = [Bpp.Windows.JobMemoryLimiter]::StartPump($startedProcess.StandardError, $stderrBuffer)
        }

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

        $stdoutPump.Wait()
        $stderrPump.Wait()
        if ($null -ne $stdoutFile) { $stdoutFile.Flush() }
        if ($null -ne $stderrFile) { $stderrFile.Flush() }

        $stdout = if ($StdoutPath) { "" } else { $utf8NoBom.GetString($stdoutBuffer.ToArray()) }
        $stderr = if ($StderrPath) { "" } else { $utf8NoBom.GetString($stderrBuffer.ToArray()) }
        $exitCode = if ($timedOut) {
            124
        } else {
            [Bpp.Windows.JobMemoryLimiter]::ExitCode($startedProcess.ProcessHandle)
        }
        $stopwatch.Stop()
        $cpuTimeMs = [Bpp.Windows.JobMemoryLimiter]::CpuTimeMilliseconds($startedProcess.ProcessHandle)

        return [PSCustomObject]@{
            ExitCode = $exitCode
            Stdout = $stdout
            Stderr = $stderr
            TimedOut = $timedOut
            WallTimeMs = [Math]::Round($stopwatch.Elapsed.TotalMilliseconds, 3)
            CpuTimeMs = [Math]::Round($cpuTimeMs, 3)
            PeakWorkingSetBytes = [Bpp.Windows.JobMemoryLimiter]::PeakProcessMemoryUsed($job)
        }
    } finally {
        if ($null -ne $stdoutFile) { $stdoutFile.Dispose() }
        if ($null -ne $stderrFile) { $stderrFile.Dispose() }
        if ($null -ne $stdoutBuffer) { $stdoutBuffer.Dispose() }
        if ($null -ne $stderrBuffer) { $stderrBuffer.Dispose() }
        if ($job -ne [IntPtr]::Zero) { [Bpp.Windows.JobMemoryLimiter]::Close($job) }
        if ($stopwatch.IsRunning) { $stopwatch.Stop() }
        if ($null -ne $startedProcess) { $startedProcess.Dispose() }
    }
}
