const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    comptime var days = [_][]const u8{ "1", "2" };
    const run_step = b.step("run", "Run the app");
    const test_step = b.step("test", "Run unit tests");
    inline for (days) |day| {
        const exe = b.addExecutable("day_" ++ day, "src/day_" ++ day ++ ".zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        // Run command
        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
        run_step.dependOn(&run_cmd.step);

        // Test
        const exe_tests = b.addTest("src/day_" ++ day ++ ".zig");
        exe_tests.setBuildMode(mode);
        test_step.dependOn(&exe_tests.step);
    }
}
