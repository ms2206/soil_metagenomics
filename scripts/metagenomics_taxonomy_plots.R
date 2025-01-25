# Disclaimer: Made with AI assistance.

library(ggplot2)
library(reshape2)
library(randomcoloR)
library(dplyr)
library(tidyr)

# Load the data
data <- read.csv("~/Downloads/level-2.csv")

# Melt the data for ggplot2
data_melted <- melt(data, id.vars = c("index", "Name", "Group"))

# Create a distinct color palette
palette <- distinctColorPalette(length(unique(data_melted$variable)))

# Grouped bar chart
ggplot(data_melted, aes(x = Group, y = value, fill = variable)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = palette) +
  labs(x = "Sample", y = "Count", title = "Microbial Composition") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  coord_flip()

# Calculate mean values by group
group_means <- data %>%
  group_by(Group) %>%
  summarise(across(starts_with("k__"), mean, na.rm = TRUE), .groups = "drop")

# Calculate log2 fold changes
log_fold_changes <- group_means %>%
  pivot_longer(cols = starts_with("k__"), names_to = "Variable", values_to = "Mean") %>%
  pivot_wider(names_from = Group, values_from = Mean) %>%
  mutate(LogFoldChange = log2(`burrawan_au` / `gilb_za`))

# Plot log2 fold changes
ggplot(log_fold_changes, aes(x = Variable, y = LogFoldChange, fill = Variable)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = palette) +
  labs(x = "Variable", y = "Log Fold Change", title = "Log Fold Changes Between Groups: burrawan_au vs gilb_za") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  coord_flip() +
  guides(fill = guide_legend(title = "Variables"))
