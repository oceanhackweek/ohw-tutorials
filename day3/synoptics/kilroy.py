# no-underscore-dir: A variant of Python 'dir' that does not report underscore attributes
def nudir(obj): return [x for x in dir(obj) if not x.startswith('__')]

# list directory contents 'ls' with the -al switch to recover details
def lsal(qualifier):  
    import os
    return os.popen('ls -al ' + qualifier).readlines()

def Show(folder, filename, width, height):
    import requests
    import shutil
    from PIL import Image
    fullpath = 'https://raw.githubusercontent.com/robfatland/othermathclub/master/images/' + folder + '/' + filename
    a = requests.get(fullpath, stream = True)
    outf = '/home/robfatland/tmp.jpg'
    if a.status_code == 200:
        with open(outf, 'wb') as f:
            a.raw.decode_content = True
            shutil.copyfileobj(a.raw, f)
    return Image.open(outf).resize((width,height),Image.ANTIALIAS)

# A proper version of 'Show' with username, repo name, folder name, sub-folder name, and filename + render dimensions
def ShowImageFromGitHub(un, rn, fn, sfn, filename, width, height):
    import requests
    import shutil
    from PIL import Image
    fullpath = 'https://raw.githubusercontent.com/' + un + '/' + \
		    rn + '/master/' + fn + '/' + sfn + '/' + filename
    a = requests.get(fullpath, stream = True)
    outf = '/home/robfatland/tmp.jpg'
    if a.status_code == 200:
        with open(outf, 'wb') as f:
            a.raw.decode_content = True
            shutil.copyfileobj(a.raw, f)
    return Image.open(outf).resize((width,height),Image.ANTIALIAS)

def ShowLocal(filename, width, height):
    import shutil
    from PIL import Image
    return Image.open(filename).resize((width,height),Image.ANTIALIAS)

def getCASite(i):
    CASites = getCASites()
    return CASites[i]

def getCASites():
    eoLat, eoLon, eoDep          = 44. + 22./60. + 10./3600., -(124. + 57./60. + 15./3600.),  582.
    osbLat, osbLon, osbDep       = 44. + 30./60. + 55./3600., -(125. + 23./60. + 23./3600.), 2906.
    shrLat, shrLon, shrDep       = 44. + 34./60. +  9./3600., -(125  +  8./60. + 53./3600.),  778.
    axbLat, axbLon, axbDep       = 45. + 49./60. +  5./3600., -(129. + 45./60. + 13./3600.), 2605.
    ashesLat, ashesLon, ashesDep = 45. + 56./60. +  1./3600., -(130. +  0./60. + 50./3600.), 1543.
    axcLat, axcLon, axcDep       = 45. + 57./60. + 17./3600., -(130. +  0./60. + 32./3600.), 1528.
    axeLat, axeLon, axeDep       = 45. + 56./60. + 23./3600., -(129. + 58./60. + 27./3600.), 1516.
    axiLat, axiLon, axiDep       = 45. + 53./60. + 35./3600., -(129. + 58./60. + 44./3600.), 1520.
    CASites = [('Endurance Offshore',                eoLat,    eoLon,    eoDep, 'Endurance Offshore'),
               ('Oregon Slope Base',                osbLat,   osbLon,   osbDep, 'Oregon Slope Base'),
               ('Southern Hydrate Ridge',           shrLat,   shrLon,   shrDep, 'Southern Hydrate Ridge'),
               ('Axial Base',                       axbLat,   axbLon,   axbDep, 'Axial Base'),
               ('Axial ASHES Vent Field',         ashesLat, ashesLon, ashesDep, 'Inferno vent'),
               ('Axial Caldera Center',             axcLat,   axcLon,   axcDep, 'Axial Caldera Center'),
               ('Axial Caldera East',               axeLat,   axeLon,   axeDep, 'Axial Caldera East'),
               ('Axial International Vent Field',   axiLat,   axiLon,   axiDep, 'Axial International Vent Field')
              ]
    return CASites

