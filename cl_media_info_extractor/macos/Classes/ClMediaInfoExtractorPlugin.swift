import Cocoa
import FlutterMacOS

public class ClMediaInfoExtractorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cl_media_info_extractor", binaryMessenger: registrar.messenger)
    let instance = ClMediaInfoExtractorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    case "launchApp" :
      guard let args = call.arguments as? [String: Any],
            let appPath = args["appPath"] as? String,
            let arguments = args["arguments"] as? [String] else {
        result(FlutterError(code: "INVALID_ARG", message: "Invalid or missing arguments", details: nil))
        return
      }

      let fileManager = FileManager.default
      var isDir: ObjCBool = false
      guard fileManager.fileExists(atPath: appPath, isDirectory: &isDir) else {
        result(FlutterError(code: "APP_NOT_FOUND", message: "Application not found at path: \(appPath)", details: nil))
        return
      }

      let process = Process()
      let stdoutPipe = Pipe()
      let stderrPipe = Pipe()

      // Set up pipes for stdout and stderr
      process.standardOutput = stdoutPipe
      process.standardError = stderrPipe

      if isDir.boolValue {
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-a", appPath] + arguments
      } else {
        process.executableURL = URL(fileURLWithPath: appPath)
        process.arguments = arguments
      }

      do {
        try process.run()

        // Wait for the process to complete (synchronous for simplicity)
        process.waitUntilExit()

        // Read stdout and stderr
        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        let stdoutStr = String(data: stdoutData, encoding: .utf8) ?? ""
        let stderrStr = String(data: stderrData, encoding: .utf8) ?? ""
        let exitCode = process.terminationStatus

        // Check termination status
        if exitCode == 0 {
          result(["stdout": stdoutStr, "stderr": stderrStr, "exitCode": exitCode])
        } else {
          result(FlutterError(code: "EXECUTION_ERROR",
                             message: "App exited with status: \(process.terminationStatus)",
                             details: ["stdout": stdoutStr, "stderr": stderrStr, exitCode: exitCode]))
        }
      } catch {
        result(FlutterError(code: "LAUNCH_ERROR", 
                           message: "Failed to launch app: \(error.localizedDescription)", 
                           details: nil))
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
