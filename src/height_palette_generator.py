import numpy as np
from skimage import color
import matplotlib.pyplot as plt
import pandas as pd
import ace_tools as tools

def generate_spiral_palette(num_colors=10, radius=40, tightness=2 * np.pi):
    # Step 1: Lightness values from dark to light
    L_vals = np.linspace(30, 90, num_colors)

    # Step 2: Spiral around a/b plane
    theta = np.linspace(0, tightness, num_colors)
    a_vals = radius * np.cos(theta)
    b_vals = radius * np.sin(theta)

    # Stack into Lab space
    lab_colors = np.stack([L_vals, a_vals, b_vals], axis=1)

    # Convert Lab to RGB
    rgb_colors = color.lab2rgb(lab_colors[np.newaxis, :, :])[0]
    rgb_colors = np.clip(rgb_colors, 0, 1)
    rgb_8bit = (rgb_colors * 255).astype(int)

    # Visualize
    fig, ax = plt.subplots(1, num_colors, figsize=(num_colors, 2))
    for i in range(num_colors):
        ax[i].imshow(np.ones((10, 10, 3)) * rgb_colors[i])
        ax[i].axis('off')
        ax[i].set_title(f"{i+1}", fontsize=8)
    plt.tight_layout()

    # Return color data
    df = pd.DataFrame(rgb_8bit, columns=["R", "G", "B"])
    df.index.name = "Index"
    return df

# Generate a sample spiral palette
palette_df = generate_spiral_palette(num_colors=10, radius=40, tightness=4 * np.pi)
tools.display_dataframe_to_user(name="Spiral Palette RGB Values", dataframe=palette_df)
