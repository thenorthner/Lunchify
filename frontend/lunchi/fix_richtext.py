import os, re

changed_files = 0
for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
            
            # This regex looks for RichText(...) and captures the inside
            # It replaces `RichText` with `Text.rich` and `text: TextSpan` with just `TextSpan`
            # But since arguments can be in any order, we can just replace `RichText(` with `Text.rich(`
            # and `text: TextSpan` with `TextSpan` inside the parens? No, Text.rich takes the textspan as positional FIRST argument.
            pass
