import sys, re, zipfile, os, os.path

dst_zip = sys.argv[1]
src_root = sys.argv[2]
classes_dirs = sys.argv[3:]

if sys.platform.startswith('darwin'):
    this_os = ['macosx', 'unix', 'share']
elif sys.platform.startswith('linux'):
    this_os = ['linux', 'unix', 'share']
elif sys.platform.startswith('win32'):
    this_os = ['windows', 'share']
elif sys.platform.startswith('sunos'):
    this_os = ['solaris', 'unix', 'share']
else:
    raise SystemExit('Unknown operating system ' + sys.platform)

module_re = re.compile(r'([^/]+/)([^/]+)/classes.*')
added = set()
with zipfile.ZipFile(dst_zip, 'w', zipfile.ZIP_DEFLATED) as zf:
    for current_os in this_os:
        for classes_dir in classes_dirs:
            relative_classes_dir = os.path.relpath(classes_dir, src_root)
            m = module_re.match(relative_classes_dir)
            system = ''
            if m:
                module_prefix = m.group(1)
                classes_os = m.group(2)
                if classes_os != current_os:
                    continue
                system = current_os
            else:
                module_prefix = ''
            count = 0
            for root, dirnames, filenames in os.walk(classes_dir):
                for filename in filenames:
                    if filename.endswith('.java'):
                        path = os.path.join(root, filename)
                        arcname = module_prefix + os.path.relpath(path, classes_dir)
                        if arcname not in added:
                            added.add(arcname)
                            zf.write(path, arcname)
                            count = count + 1
            if count != 0:
                print "{} Added {} sources from {} for module {}".format(system, count, classes_dir, module_prefix)
