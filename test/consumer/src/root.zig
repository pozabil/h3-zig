const std = @import("std");
const h3 = @import("h3");

test "consumer imports h3 module and uses safe wrappers" {
    const cell = try h3.latLngToCell(h3.latLngDegrees(40.689167, -74.044444), 10);
    try std.testing.expect(h3.isValidCell(cell));

    var buffer: [h3.h3StringBufferLength]u8 = undefined;
    const text = try h3.h3ToString(cell, &buffer);
    try std.testing.expectEqualStrings("8a2a1072b59ffff", text);
}

test "consumer imports raw C API through h3.raw" {
    const coord = h3.latLngDegrees(40.689167, -74.044444);
    var cell: h3.H3Index = 0;

    try std.testing.expectEqual(
        @as(h3.H3Error, h3.c.E_SUCCESS),
        h3.raw.latLngToCell(&coord, 10, &cell),
    );
    try std.testing.expect(h3.raw.isValidCell(cell) != 0);
}
