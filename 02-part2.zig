const std = @import("std");

const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

fn isListSafe(list: ArrayList(i32)) bool {
    // If the list is too short, we just count it as unsafe
    if (list.items.len < 2) {
        return false;
    }

    // Variable indicating if the list increasing or decreasing
    const decreasing: bool = if ((list.items[0] - list.items[1]) > 0) true else false;

    // Iterate over n-1 of the items in the list as we don't need to have the
    // last item in `number`
    for (list.items[0..(list.items.len - 1)], 0..) |number, idx| {
        const diff = number - list.items[idx + 1];

        // Exit early if we're supposed to be decreasing
        if (decreasing and diff <= 0) {
            std.debug.print("  List is supposed to decrease, exit loop\n", .{});
            return false;
        }

        if (!decreasing and diff > 0) {
            std.debug.print("  List is supposed to increase, exit loop\n", .{});
            return false;
        }

        switch (@abs(diff)) {
            // If at least one and at most 3 (with any sign), then we happy
            1, 2, 3 => continue,
            // End this loop
            else => {
                std.debug.print("  Found list is unsafe because diff is {any}\n", .{diff});
                return false;
            },
        }
    }

    return true;
}

// Super ridiculous way of doing this XD
//
// For a list, return all the lists that have 'dampening'
// applied, that is: an element removed, which we can then apply
// and see if removing an element can do the trick of making the list
// 'safe'
fn dampenedLists(list: ArrayList(i32)) error{OutOfMemory}!ArrayList(ArrayList(i32)) {
    var allDampenedLists = ArrayList(ArrayList(i32)).init(allocator);

    for (0..list.items.len) |i| {
        var dampenedList = ArrayList(i32).init(allocator);
        for (list.items, 0..) |item, j| {
            if (i != j) {
                try dampenedList.append(item);
            }
        }

        try allDampenedLists.append(dampenedList);
    }

    return allDampenedLists;
}

pub fn main() !void {
    std.debug.print("Day 2: Red-Nosed Reports\n", .{});
    std.debug.print("========================\n", .{});

    std.debug.print("Reading file\n", .{});
    var file = try std.fs.cwd().openFile("02.input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

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
        if (!isListSafe(list)) {
            std.debug.print("List {any} is not safe, but will attempt to dampen it and see: {any}\n", .{ ldx, list.items });
            const dampened = try dampenedLists(list);
            defer dampened.deinit();

            for (dampened.items) |dampenedList| {
                std.debug.print("  Checking dampened list {any}\n", .{dampenedList.items});
                if (isListSafe(dampenedList)) {
                    std.debug.print("  List {any} is safe if dampened\n", .{ldx});
                    safeLists = safeLists + 1;
                    continue :outer;
                }
            }

            // We still didn't find a safe list even if dampened so... ¯\_(ツ)_/¯
            continue :outer;
        }

        // If we didn't `continue` above then it must be safe
        // std.debug.print("List {any} is safe!\n", .{ldx});
        safeLists = safeLists + 1;
    }

    std.debug.print("Result: {}\n", .{safeLists});
}
