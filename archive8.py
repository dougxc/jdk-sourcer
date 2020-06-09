import sys, re, zipfile, os, os.path

dst_zip = sys.argv[1]
classes_dirs = sys.argv[3:]

if sys.platform.startswith('darwin'):
    this_os = ['macosx', 'solaris', 'share', 'common']
elif sys.platform.startswith('linux'):
    this_os = ['solaris', 'share', 'common']
elif sys.platform.startswith('win32'):
    this_os = ['windows', 'share', 'common']
elif sys.platform.startswith('sunos'):
    this_os = ['solaris', 'share', 'common']
else:
    raise SystemExit('Unknown operating system ' + sys.platform)

added = set()
with zipfile.ZipFile(dst_zip, 'w', zipfile.ZIP_DEFLATED) as zf:
    for current_os in this_os:
        for classes_dir in classes_dirs:
            parent_dir = os.path.basename(os.path.dirname(classes_dir))
            if current_os != parent_dir:
                continue
            system = parent_dir
            count = 0
            for root, dirnames, filenames in os.walk(classes_dir):
                for filename in filenames:
                    if filename.endswith('.java'):
                        path = os.path.join(root, filename)
                        arcname = os.path.relpath(path, classes_dir)
                        if arcname not in added:
                            added.add(arcname)
                            zf.write(path, arcname)
                            count = count + 1
            if count != 0:
                print "{} Added {} sources from {}".format(system, count, classes_dir)
