This is my project meant to help reproduce the issues seen in [TTTAttributedLabel Issue #616](https://github.com/TTTAttributedLabel/TTTAttributedLabel/issues/616)

This issue happens when the line at `numberOfLines - 1` is a new line character as follows:
```
// Assuming numberOfLines = 3

For the text: "EH\n\n\nWorld", these are the lines and their line number (0-based)
"""
0. EH\n
1. \n
2. \n
3. World
"""
```

I've narrowed it down to this method
```objective-c
-[TTTAttributedLabel  drawFramesetter:attributedString:textRange:inRect:context:]
```

The range for the `\n` (line 2) above (aka `lastLineRange`) is `location: 4, length: 1`.
However, this next snippet will actually remove and make it `""` and then append the truncationString (`...more` in my case).

```objective-c
// Line: 863
if (lastLineRange.length > 0) {
    // Remove any newline at the end (we don't want newline space between the text and the truncation token). There can only be one, because the second would be on the next line.
    unichar lastCharacter = [[truncationString string] characterAtIndex:(NSUInteger)(lastLineRange.length - 1)];
    if ([[NSCharacterSet newlineCharacterSet] characterIsMember:lastCharacter]) {
        [truncationString deleteCharactersInRange:NSMakeRange((NSUInteger)(lastLineRange.length - 1), 1)];
    }
}
[truncationString appendAttributedString:attributedTruncationString];
```

As mentioned in the issue, when you have set `NSLinkAttributeName` then you'll enter another bit of logic around line 885.
Note at this point the `truncationString` is now just `...more` which is equal to `attributedTruncationString`. 
`tokenRange` is now just `location: 0, length: 7`

```objective-c
// Line: 885
NSRange linkRange;
if ([attributedTruncationString attribute:NSLinkAttributeName atIndex:0 effectiveRange:&linkRange]) {
    NSRange tokenRange = [truncationString.string rangeOfString:attributedTruncationString.string];
    NSRange tokenLinkRange = NSMakeRange((NSUInteger)(lastLineRange.location+lastLineRange.length)-tokenRange.length, (NSUInteger)tokenRange.length);
    
    [self addLinkToURL:[attributedTruncationString attribute:NSLinkAttributeName atIndex:0 effectiveRange:&linkRange] withRange:tokenLinkRange];
}
```

The line that sets the `tokenLinkRange` is what causes the issue.
When the `lastLineRange` representing the last line has a length less than the truncation tokens length (`...more`) then this will crash.
```objective-c
// This is equivalent to below where tokenRange is range of 
// (4 + 1) - (7) = -2 but not represented in unsigned and goes to max representation of `NSUInteger`
// which is a large number that causes an out of bounds error
(lastLineRange.location+lastLineRange.length)-tokenRange.length
```

TLDR: When the last line has a length less than the truncationToken string's length then this will crash.
