##############################################################################
# Example scripts to generate heatmaps using the pheatmap library
# 
# Code adapted from
#   https://cran.r-project.org/web/packages/pheatmap/pheatmap.pdf
#
# Installation:
#   install.packages("dendsort")
#   install.packages("pheatmap")
##############################################################################


##########################
# Load library
##########################
library(pheatmap)
library(dendsort)

##########################
# Create test matrix
#   Rows are genes,
#   Columns are patients
##########################
test = matrix(rnorm(200), 20, 10)
test[1:10, seq(1, 10, 2)] = test[1:10, seq(1, 10, 2)] + 3
test[11:20, seq(2, 10, 2)] = test[11:20, seq(2, 10, 2)] + 2
test[15:20, seq(2, 10, 2)] = test[15:20, seq(2, 10, 2)] + 4
colnames(test) = paste("Patient", 1:10, sep = "")
rownames(test) = paste("Gene", 1:20, sep = "")

##########################
# Draw heatmaps
##########################
pheatmap(test)
pheatmap(test, kmeans_k = 2)
pheatmap(test, scale = "row", clustering_distance_rows = "correlation")
pheatmap(test, color = colorRampPalette(c("navy", "white", "firebrick3"))(50))
pheatmap(test, cluster_row = FALSE)
pheatmap(test, legend = FALSE)

##########################
# Show text within cells
##########################
pheatmap(test, display_numbers = TRUE)
#pheatmap(test, display_numbers = TRUE, number_format = "\%.1e")
pheatmap(test, display_numbers = matrix(ifelse(test > 5, "*", ""), nrow(test)))
pheatmap(test, cluster_row = FALSE, legend_breaks = -1:4, legend_labels = c("0",
                                                                            "1e-4", "1e-3", "1e-2", "1e-1", "1"))

####################################################
# Fix cell sizes and save to file with correct size
####################################################
pheatmap(test, cellwidth = 15, cellheight = 12, main = "Example heatmap")
pheatmap(test, cellwidth = 15, cellheight = 12, fontsize = 8, filename = "test.pdf")

####################################################
# Generate annotations for rows and columns
####################################################
annotation_col = data.frame(
  CellType = factor(rep(c("CT1", "CT2"), 5)),
  Time = 1:5
)
rownames(annotation_col) = paste("Patient", 1:10, sep = "")
annotation_row = data.frame(
  GeneClass = factor(rep(c("Path1", "Path2", "Path3"), c(10, 4, 6)))
)
rownames(annotation_row) = paste("Gene", 1:20, sep = "")

####################################################
# Display row and color annotations
####################################################
pheatmap(test, annotation_col = annotation_col)
pheatmap(test, annotation_col = annotation_col, annotation_legend = FALSE)
pheatmap(test, annotation_col = annotation_col, annotation_row = annotation_row)


##########################
# Specify colors
##########################
ann_colors = list(
  Time = c("white", "firebrick"),
  CellType = c(CT1 = "#1B9E77", CT2 = "#D95F02"),
  GeneClass = c(Path1 = "#7570B3", Path2 = "#E7298A", Path3 = "#66A61E")
)
pheatmap(test, annotation_col = annotation_col, annotation_colors = ann_colors, main = "Title")
pheatmap(test, annotation_col = annotation_col, annotation_row = annotation_row,
         annotation_colors = ann_colors)
pheatmap(test, annotation_col = annotation_col, annotation_colors = ann_colors[2])

###############################
# Gaps in heatmaps
# AND
# do not cluster rows
#  using cluster_rows = FALSE
###############################

pheatmap(test, annotation_col = annotation_col, cluster_rows = FALSE, gaps_row = c(10, 14))
pheatmap(test, annotation_col = annotation_col, cluster_rows = FALSE, gaps_row = c(10, 14),
         cutree_col = 2)

####################################################
# Show custom strings as row/col names
####################################################
labels_row = c("", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
               "", "", "IL10", "IL15", "IL1B")
pheatmap(test, annotation_col = annotation_col, labels_row = labels_row)


#####################################################
# Morpheus style heatmap that looks prettier
#####################################################
pheatmap(test, annotation_col = annotation_col, labels_row = labels_row,
         show_colnames = FALSE,
         fontsize = 10, cellwidth = 3, cellheight = 8#,filename = "Metagene_score.pdf"
         )

####################################################
# Specifying clustering from distance matrix
####################################################
drows = dist(test, method = "minkowski", p=1.4)
dcols = dist(t(test), method = "minkowski", p=1.4)
pheatmap(test, clustering_distance_rows = drows, clustering_distance_cols = dcols)

#########################################################################
# Modify ordering of the clusters using clustering callback option
#########################################################################
callback = function(hc, mat){
  sv = svd(t(mat))$v[,1]
  dend = reorder(as.dendrogram(hc), wts = sv)
  as.hclust(dend)
}
pheatmap(test, clustering_callback = callback)

#########################################################################
# Modify ordering of the clusters using clustering callback option
#  using dendsort package
#########################################################################
library(dendsort)
callback = function(hc, ...){dendsort(hc)}
pheatmap(test, clustering_callback = callback)

