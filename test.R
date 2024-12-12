# Install and load required packages
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(tidyr)) install.packages("tidyr")
if (!require(dplyr)) install.packages("dplyr")
if (!require(tikzDevice)) install.packages("tikzDevice")
if (!require(ggExtra)) install.packages("ggExtra")
if (!require(viridis)) install.packages("viridis")
if (!require(scales)) install.packages("scales")
if (!require(colorspace)) install.packages("colorspace")

library(viridis)
library(scales)
library(colorspace)
library(ggplot2)
library(tidyr)
library(dplyr)
library(tikzDevice)
library(ggExtra)

# Set up tikzDevice options
options(tikzDefaultEngine = "luatex")
options(tikzLatexPackages = c(
    "\\usepackage{tikz}",
    "\\usepackage{amsmath}",
    "\\usepackage{amssymb}",
    "\\usepackage[T1]{fontenc}",
    "\\usepackage{lmodern}"
))

# Generate more interesting sample data
set.seed(123)
n <- 150
data <- data.frame(
    x = rnorm(n, mean = rep(c(-1, 0, 1), each = n / 3), sd = 0.5),
    y = rnorm(n, mean = rep(c(-0.5, 0.5, 0), each = n / 3), sd = 0.5),
    group = factor(rep(c("A", "B", "C"), each = n / 3),
        levels = c("A", "B", "C"),
        labels = c("Group A", "Group B", "Group C")
    ),
    size = runif(n, 1, 5),
    value = rnorm(n)
)

# Create enhanced base plot
p <- ggplot(data, aes(x = x, y = y)) +
    # Add contours for better density visualization
    stat_density_2d(aes(alpha = after_stat(density)),
        geom = "tile",
        contour = FALSE,
        n = 200
    ) +
    scale_alpha_continuous(range = c(0, 0.3), guide = "none") +

    # Add points with enhanced aesthetics
    geom_point(
        aes(
            color = group,
            size = size,
            alpha = size
        ),
        stroke = 0.25
    ) +

    # Add smoothed conditional means with custom settings
    geom_smooth(aes(color = group),
        method = "loess",
        se = TRUE,
        level = 0.95,
        linewidth = 1,
        alpha = 0.2
    ) +

    # Custom color scales
    scale_color_viridis_d(option = "turbo", end = 0.8) +
    scale_size_continuous(
        range = c(1, 4),
        guide = "none"
    ) +

    # Simplified labels and titles
    labs(
        title = "Distribution Patterns Across Groups",
        subtitle = "Density, size, and group relationships",
        x = "X Position",
        y = "Y Position",
        color = "Category",
        caption = "Shaded regions represent confidence intervals"
    ) +

    # Enhanced theme customization
    theme_minimal() +
    theme(
        text = element_text(family = "Latin Modern Roman"),
        plot.title = element_text(size = 14, face = "bold", margin = margin(b = 10)),
        plot.subtitle = element_text(size = 11, color = "gray30", margin = margin(b = 10)),
        plot.caption = element_text(size = 9, color = "gray30", margin = margin(t = 10)),
        legend.position = "right",
        legend.title = element_text(face = "bold"),
        legend.text = element_text(size = 9),
        panel.grid.minor = element_line(color = "gray95"),
        panel.grid.major = element_line(color = "gray90"),
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA),
        axis.text = element_text(size = 9),
        axis.title = element_text(size = 10)
    ) +

    # Set proper plot dimensions
    coord_cartesian(clip = "off") +
    scale_x_continuous(breaks = pretty_breaks(n = 6)) +
    scale_y_continuous(breaks = pretty_breaks(n = 6))

# Add enhanced marginal plots
p_with_marginals <- ggMarginal(p,
    type = "density",
    fill = "lightblue",
    alpha = 0.5,
    size = 0.5,
    margins = "both",
    color = "gray30"
)

# Save using tikzDevice with improved settings
tikz("complex_plot.tex",
    width = 8,
    height = 7,
    sanitize = TRUE,
    pointsize = 11
)
print(p_with_marginals)
dev.off()
