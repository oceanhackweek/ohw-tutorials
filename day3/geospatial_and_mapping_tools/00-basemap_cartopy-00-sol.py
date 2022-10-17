ax0 = plt.axes();
ax1 = plt.axes(projection=ccrs.PlateCarree());

mpl = [obj for obj in dir(ax0) if not obj.startswith('_')]
cart = [obj for obj in dir(ax1) if not obj.startswith('_')]

print(set(mpl).symmetric_difference(cart))
print(ax1.get_extent())