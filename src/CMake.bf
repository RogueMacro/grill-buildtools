using System;
using System.IO;

namespace BuildTools
{
	public static class CMake
	{
		public class Command
		{
			public int32 ExitCode { get; private set; };
			private String OutputFilePath ~ delete _;

			public ~this()
			{
				File.Delete(OutputFilePath);
			}

			private void Set(int32 exitCode, String outputFilePath)
			{
				ExitCode = exitCode;
				OutputFilePath = outputFilePath;
			}

			public Result<void, FileError> ReadOutput(String buffer)
			{
				return File.ReadAllText(OutputFilePath, buffer);
			}
		}

		public enum CommandError
		{
			PipeError,
			ProcessCreationError,
		}

		public static bool IsAvailable
		{
			get => Run("--version") case .Ok;
		}

		public static Result<void, CommandError> Run(StringView args, bool redirectStdout = false)
		{
			return Run(args, scope .(), redirectStdout);
		}

		public static Result<void, CommandError> Run(StringView args, Command outCommand, bool redirectStdout = false)
		{
			var sa = SecurityAttributes();
			sa.[Friend]mInheritHandle = 1;

			Windows.Handle childStdOutRd = Windows.Handle.NullHandle;
			Windows.Handle childStdOutWr = Windows.Handle.NullHandle;
			if (!Windows.CreatePipe(out childStdOutRd, out childStdOutWr, &sa, 0))
				return .Err(.PipeError);

			var pi = Windows.ProcessInformation();
			var si = Windows.StartupInfo();
			si.mStdError = (.)childStdOutWr;
			si.mStdOutput = (.)childStdOutWr;
			si.mShowWindow = Windows.SW_HIDE;
			si.mFlags |= Windows.STARTF_USESTDHANDLES;
			si.mFlags |= 0x00000001; // STARTF_USESSHOWWINDOW

			if (!Windows.CreateProcessA(null, scope $"cmake {args}", null, null, true, 0x00000010, null, null, &si, &pi))
				return .Err(.ProcessCreationError);

			Windows.CloseHandle(childStdOutWr);

			let outputFilePath = Path.GetTempPath(.. new .());
			Path.InternalCombine(outputFilePath, "grill-cmake");
			if (!Directory.Exists(outputFilePath))
				Directory.CreateDirectory(outputFilePath);
			Path.InternalCombine(outputFilePath, scope Random().NextU32().ToString(.. scope .()));

			int32 dwRead, dwWritten;
			char8[1024] chBuf;
			Windows.IntBool success = false;
			Windows.Handle parentStdOut = Windows.CreateFileA(outputFilePath, Windows.GENERIC_WRITE, 0, null, FileMode.OpenOrCreate, 0x100, Windows.Handle.NullHandle);

			while (true)
			{
				success = (.)Windows.ReadFile(childStdOutRd, (.)&chBuf, 1024, out dwRead, null);
				if (!success || dwRead == 0) break;

				if (redirectStdout)
					Windows.WriteFile(Windows.GetStdHandle(Windows.STD_OUTPUT_HANDLE), (.)&chBuf, dwRead, out dwWritten, null);

				success = (.)Windows.WriteFile(parentStdOut, (.)&chBuf, dwRead, out dwWritten, null);
				if (!success) break;

			}

			let exitCode = Windows.WaitForSingleObject(pi.mProcess, int32.MaxValue);

			Windows.CloseHandle(childStdOutRd);
			Windows.CloseHandle(parentStdOut);
			Windows.CloseHandle(pi.mProcess);
			Windows.CloseHandle(pi.mThread);


			outCommand.[Friend]Set(exitCode, outputFilePath);
			return .Ok;
		}
	}
}