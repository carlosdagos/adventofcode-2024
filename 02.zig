const std = @import("std");

pub fn main() !void {
    std.debug.print("Day 2: Red-Nosed Reports\n", .{});
    std.debug.print("========================\n", .{});

    std.debug.print("Reading file\n", .{});
    var file = try std.fs.cwd().openFile("02.input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    const ArrayList = std.ArrayList;
    const allocator = std.heap.page_allocator;

    var allLists = ArrayList(ArrayList(i32)).init(allocator);
    defer allLists.deinit();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var numberList = ArrayList(i32).init(allocator);
        var tokenizer = std.mem.tokenizeScalar(u8, line, ' ');

        while (tokenizer.next()) |entry| {
            const number = std.fmt.parseInt(i32, entry, 10) catch {
                std.debug.print("Failed to convert entry {s} to integer\n", .{entry});
                return;
            };

            try numberList.append(number);
        }

        try allLists.append(numberList);
    }

    std.debug.print("Calculating safe lists out of {any}\n", .{allLists.items.len});

    var safeLists: i32 = 0;
    outer: for (allLists.items, 0..) |list, ldx| {
        // If the list is too short, we just count it as unsafe
        if (list.items.len < 2) {
            continue :outer;
        }

        // Variable indicating if the list increasing or decreasing
        const decreasing: bool = if ((list.items[0] - list.items[1]) > 0) true else false;

        // Iterate over n-1 of the items in the list as we don't need to have the
        // last item in `number`
        for (list.items[0..(list.items.len - 1)], 0..) |number, idx| {
            const diff = number - list.items[idx + 1];

            // Exit early if we're supposed to be decreasing
            if (decreasing and diff <= 0) {
                std.debug.print("List {any} is supposed to decrease, exit loop\n", .{ldx});
                continue :outer;
            }

            if (!decreasing and diff > 0) {
                std.debug.print("List {any} is supposed to increase, exit loop\n", .{ldx});
                continue :outer;
            }

            switch (@abs(diff)) {
                // If at least one and at most 3 (with any sign), then we happy
                1, 2, 3 => continue,
                // End this loop
                else => {
                    std.debug.print("Found {any} is unsafe\n", .{ldx});
                    continue :outer;
                },
            }
        }

        // If we didn't `continue` above then it must be safe
        std.debug.print("List {any} is safe!\n", .{ldx});
        safeLists = safeLists + 1;
    }

    std.debug.print("Result: {}\n", .{safeLists});
}
