import sys, re, zipfile, os, os.path

dst_zip = sys.argv[1]
classes_dirs = sys.argv[2:]

if sys.platform.startswith('darwin'):
    this_os = ['macosx', 'unix', 'share']
elif sys.platform.startswith('linux'):
    this_os = ['linux', 'unix', 'share']
elif sys.platform.startswith('win32'):
    this_os = ['windows', 'share']
elif sys.platform.startswith('sunos'):
    this_os = ['solaris', 'unix', 'share']
else:
    abort('Unknown operating system ' + sys.platform)

module_re = re.compile(r'src/([^/]+/)([^/]+)/classes.*')
added = set()
with zipfile.ZipFile(dst_zip, 'w', zipfile.ZIP_DEFLATED) as zf:
    for current_os in this_os:
        for classes_dir in classes_dirs:
            m = module_re.match(classes_dir)
            system = ''
            if m:
                module_prefix = m.group(1)
                classes_os = m.group(2)
                if classes_os != current_os:
                    continue
            else:
                module_prefix = ''
            print "{} Adding sources from {} for module {} ...".format(system, classes_dir, module_prefix)
            for root, dirnames, filenames in os.walk(classes_dir):
                for filename in filenames:
                    if filename.endswith('.java'):
                        path = os.path.join(root, filename)
                        arcname = module_prefix + os.path.relpath(path, classes_dir)
                        if arcname not in added:
                            added.add(arcname)
                            zf.write(path, arcname)
