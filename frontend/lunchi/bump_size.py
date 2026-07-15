import os, re

def process_line(line):
    if 'FontWeight.bold' in line or 'FontWeight.w700' in line or 'FontWeight.w800' in line:
        # Check if fontSize exists on this line
        match = re.search(r'fontSize:\s*([\d\.]+)', line)
        if match:
            old_size_str = match.group(1)
            # handle floats just in case
            old_size = float(old_size_str) if '.' in old_size_str else int(old_size_str)
            new_size = old_size + 2
            
            # Format to avoid .0 for ints
            new_size_str = str(int(new_size)) if new_size == int(new_size) else str(new_size)
            
            line = line.replace(f'fontSize: {old_size_str}', f'fontSize: {new_size_str}')
    return line

changed_files = 0
for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r') as f:
                lines = f.readlines()
            
            new_lines = []
            changed = False
            for line in lines:
                new_line = process_line(line)
                if new_line != line:
                    changed = True
                new_lines.append(new_line)
            
            if changed:
                with open(path, 'w') as f:
                    f.writelines(new_lines)
                changed_files += 1

print(f"Changed {changed_files} files.")
