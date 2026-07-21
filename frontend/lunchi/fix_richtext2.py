import os, re

changed_files = 0
for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                content = f.read()
            
            # Find RichText block and replace the first text: const TextSpan or text: TextSpan
            # with one that has fontFamily: 'Typewriter' inside its style if not present.
            
            def replacer(match):
                inner_span = match.group(2)
                # If there's no style, it's hard to inject blindly.
                if 'style: TextStyle(' in inner_span and 'fontFamily:' not in inner_span:
                    inner_span = inner_span.replace('style: TextStyle(', "style: TextStyle(fontFamily: 'Typewriter', ")
                elif 'style: const TextStyle(' in inner_span and 'fontFamily:' not in inner_span:
                    inner_span = inner_span.replace('style: const TextStyle(', "style: const TextStyle(fontFamily: 'Typewriter', ")
                elif 'style:' not in inner_span:
                    # Inject a style
                    if 'children:' in inner_span:
                        inner_span = inner_span.replace('children:', "style: const TextStyle(fontFamily: 'Typewriter'),\nchildren:")
                    elif 'text:' in inner_span:
                         inner_span = inner_span.replace('text:', "style: const TextStyle(fontFamily: 'Typewriter'),\ntext:")
                return 'RichText(' + match.group(1) + 'text: ' + inner_span
                
            new_content = re.sub(r'RichText\((.*?)\btext:\s*(const TextSpan\(|TextSpan\()', replacer, content, flags=re.DOTALL)
            
            if new_content != content:
                with open(path, 'w') as f:
                    f.write(new_content)
                changed_files += 1

print(f"Changed {changed_files} files.")
