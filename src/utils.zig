pub fn StaticArrayList(comptime T: type, len: usize) type {
    return struct {
        arr: [len]T = undefined,
        i: usize = 0,
        pub fn push(self: *@This(), value: T) void {
            self.arr[self.i] = value;
            self.i += 1;
        }
    };
}

const Cell = []const u8;

pub fn transpose(table: anytype) [childLen(@TypeOf(table.*))][table.len]Cell {
    var transposed: [childLen(@TypeOf(table.*))][table.len]Cell = undefined;
    for (table, 0..) |row, i| {
        for (row, 0..) |cell, j| transposed[j][i] = cell;
    }
    return transposed;
}

pub const Align = enum { Left, Center, Right };
pub fn writeAlign(w: anytype, text: []const u8, width: usize, alignment: Align) !void {
    const rem_space = width - text.len;
    var padding = [_]usize{ 0, 0 };
    switch (alignment) {
        .Left => padding[1] = rem_space,
        .Right => padding[0] = rem_space,
        .Center => {
            padding[0] = rem_space / 2;
            padding[1] = rem_space - padding[0];
        },
    }
    try w.writeByteNTimes(' ', padding[0] + 1);
    try w.writeAll(text);
    try w.writeByteNTimes(' ', padding[1] + 1);
}

pub fn childLen(comptime T: type) comptime_int {
    return @typeInfo(@typeInfo(T).array.child).array.len;
}
