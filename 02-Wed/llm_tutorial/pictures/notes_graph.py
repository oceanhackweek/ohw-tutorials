import matplotlib.pyplot as plt
import matplotlib.font_manager as fm

# Load the xkcd script font, which has to be downloaded first from https://github.com/ipython/xkcd-font
font_path = '/usr/share/fonts/truetype/xkcd-script/xkcd-script.ttf'  # Ensure this path is correct
font_prop = fm.FontProperties(fname=font_path)

#toggle xkcd styling
plt.xkcd()

fig, ax = plt.subplots(1,figsize = (4,4))
#ax = fig.add_axes((0.1, 0.2, 0.8, 0.7))
ax.spines[['top', 'right']].set_visible(False)
ax.set_xticks([])
ax.set_yticks([])
ax.set_ylabel('shareability', fontproperties=font_prop, fontsize = 18)
# Customize x-tick labels with the xkcd font
ax.set_xticks(ticks=[1, 3], labels=['short-time', 'long-time'], fontproperties=font_prop, fontsize = 18)
ax.set_xlim(0.5,3.5)    
ax.set_ylim(0.5,3.5)  # Set y-axis limits to ensure text is visible

# Common kwargs for text
text_kwargs = {
    'fontproperties': font_prop,
    'ha': 'center',
    'va': 'center',
    'fontsize': 18
}
ax.text(1, 1, 'Post-its',  **text_kwargs)
ax.text(2, 1.5, 'Notebook', **text_kwargs)
ax.text(3, 3, 'Wiki', **text_kwargs)

fig.tight_layout()
plt.savefig("./notes_graph.svg")  


###
#   Version 2
###
fig, ax = plt.subplots(1, figsize=(6, 4))  # Swapping the figure size
ax.spines[['top', 'right']].set_visible(False)
ax.set_xticks([])
ax.set_yticks([])
ax.set_ylabel('shareability', fontproperties=font_prop, fontsize=18)  # Swapping xlabel to ylabel
ax.set_xticks(ticks=[1, 3], labels=['short-time', 'long-time'], fontproperties=font_prop, fontsize=18)  # Swapping yticks to xticks
ax.set_ylim(0, 3.5)    
ax.set_xlim(0.5, 4)  # Set x-axis limits to ensure text is visible

# Categories
ax.axhline(0.8, ls = ":", color = "gray")
ax.axhline(2.3, ls = ":", color = "gray")
ax.axhline(3.3, ls = ":", color = "gray")

text_kwargs = {
    'fontproperties': font_prop,
    'ha': 'right',  
    'va': 'center',  
    'fontsize': 18,
    'color': 'gray',
}
ax.text(3.9, 0.6, 'Post-its',  **text_kwargs)  
ax.text(3.9, 2.1, 'Notebook', **text_kwargs)  
ax.text(3.9, 3.1, 'Wiki', **text_kwargs)  

# Contents
text_kwargs = {
    'fontproperties': font_prop,
    'ha': 'center',
    'va': 'center',
    'fontsize': 18,
    'color': 'k',
}

# post-its
ax.text(1, 0.4, 'daily\nto-do lists',  **text_kwargs)
# Notebook
ax.text(1.5, 1.2, 'sketches',  **text_kwargs)  
ax.text(2.1, 1.8, 'thoughts\nabout thesis',  **text_kwargs)  
# Wiki
ax.text(2.8, 2.6, 'software', **text_kwargs)  
ax.text(3.2, 3, 'tutorials', **text_kwargs)  
    
fig.tight_layout()
plt.savefig("./notes_graph2.svg")  

plt.show()

