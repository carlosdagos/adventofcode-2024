const std = @import("std");

pub fn main() !void {
    std.debug.print("Day 1: Historian Hysteria\n", .{});
    std.debug.print("===========================\n", .{});

    std.debug.print("Reading file\n", .{});
    var file = try std.fs.cwd().openFile("01.input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    const ArrayList = std.ArrayList;
    const allocator = std.heap.page_allocator;

    var list1 = ArrayList(i32).init(allocator);
    var list2 = ArrayList(i32).init(allocator);

    defer list1.deinit();
    defer list2.deinit();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var tokenizer = std.mem.tokenize(u8, line, " ");

        const first_number_str = tokenizer.next() orelse {
            std.debug.print("Failed to parse first number\n", .{});
            return;
        };

        const second_number_str = tokenizer.next() orelse {
            std.debug.print("Failed to parse second number\n", .{});
            return;
        };

        const first_number = std.fmt.parseInt(i32, first_number_str, 10) catch {
            std.debug.print("Failed to convert first number to integer\n", .{});
            return;
        };
        const second_number = std.fmt.parseInt(i32, second_number_str, 10) catch {
            std.debug.print("Failed to convert second number to integer\n", .{});
            return;
        };

        try list1.append(first_number);
        try list2.append(second_number);
    }

    std.debug.print("Calculating distances\n", .{});

    std.mem.sort(i32, list1.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, list2.items, {}, comptime std.sort.asc(i32));

    var result: u32 = 0;
    for (list1.items, list2.items) |item1, item2| {
        const dist = @abs(item1 - item2);
        result = result + dist;
    }

    std.debug.print("Result: {}\n", .{result});
}
