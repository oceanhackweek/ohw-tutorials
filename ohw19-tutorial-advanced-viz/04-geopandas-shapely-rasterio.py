br = countries[countries['name'] == 'Brazil'].geometry.squeeze()

intersec = countries[countries.intersects(br)]

intersec