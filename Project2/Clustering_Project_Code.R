#------------------------- Msc In Statistics AUEB ---------------------------
#
# Purpose: Clustering Project in Course Statistical Machine Learning. 
# This project aims to explore the age composition of Greece's population 
# based on the 2001 census data. The data comprises the number of individuals in 
# various age groups for each municipal district. The primary goal is to identify 
# clusters of municipalities that share similar age compositions, determine the 
# optimal number of clusters, and characterize these clusters.
#
# We employ two clustering methods: Hierarchical Clustering and Model-Based Clustering.
# Hierarchical Clustering is performed using different linkage methods (Ward, Complete, 
# Single, and Average) and different distance metrics (Mahalanobis, Euclidean, Manhattan, 
# and Gower). Model-Based Clustering is carried out using Gaussian Mixture Models.
#
# Additionally, we use various evaluation metrics and visualization techniques 
# such as Silhouette Analysis, Wilks' Lambda, and Principal Component Analysis (PCA) 
# to validate and interpret the clustering results.
#
#
# Author: Konstantinos Grammenos
# 
# #Date: 1/6/2024
#
# Proffesor:D.Karlis


#-------------------------LOAD NECESSARY LIBRARIES------------------------------

###trick to install the pacages we need automatically
packs<-c("corrgram","HDclassif","cluster","mclust","FactMixtAnalysis",
         "nnet","class","tree", "pgmm")
library(readxl)
library(corrgram)
library(HDclassif)
library(cluster)
library(mclust)
library(nnet)
library(class)
library(tree)
library(dplyr)
library(readr)
library(ggplot2)
library(purrr)
library(reshape2)
library(factoextra)
library(dplyr)
library(corrplot)
library(gridExtra)

###-------------------LOAD THE DATA -------------------------

Sys.setlocale(category = "LC_ALL", locale = "Greek")
path <- "C://Users//kosti//OneDrive//Desktop//Statistical Machine Learning//Project2//greek data.xls"
data <- read_excel(path,skip=3)
head(data)
data <- data[, -1]
head(data)

print(colnames(data))

#-------------DATA PROCESSING ---------------------

# Rename a specific column
colnames(data)[colnames(data) == "Γεωγρα-\nφικός Κωδικός" ] <- "Geographical Code"
colnames(data)[colnames(data) == "Σύνολο Ελλάδος,Γεωγραφική ζώνη ( NUTS I), περιφέρεια ( NUTS II ) , νομός, δήμος / κοινότητα και δημοτικό / κοινοτικό διαμέρισμα."] <- "Municipality"
colnames(data)[colnames(data) == "Αμφοτέρων των φύλων"] <- "Both Genders Sum"
colnames(data)[colnames(data) == "...5"] <- "Both Genders 0-14"
colnames(data)[colnames(data) == "...6"] <- "Both Genders 15-24"
colnames(data)[colnames(data) == "...7"] <- "Both Genders 25-39"
colnames(data)[colnames(data) == "...8"] <- "Both Genders 40-54"
colnames(data)[colnames(data) == "...9"] <- "Both Genders 55-64"
colnames(data)[colnames(data) == "...10"] <- "Both Genders 65-79"
colnames(data)[colnames(data) == "...11"] <- "Both Genders 80+"
colnames(data)[colnames(data) == "Σύνολο...12"] <- "Males Sum"
colnames(data)[colnames(data) ==  "΄Αρρενες"] <- "Males 0-14"
colnames(data)[colnames(data) == "...14"] <- "Males 15-24"
colnames(data)[colnames(data) == "...15"] <- "Males 25-39"
colnames(data)[colnames(data) == "...16"] <- "Males 40-54"
colnames(data)[colnames(data) == "...17"] <- "Males 55-64"
colnames(data)[colnames(data) == "...18"] <- "Males 65-79"
colnames(data)[colnames(data) == "...19"] <- "Males 80+"
colnames(data)[colnames(data) == "Σύνολο...20"] <- "Females Sum"
colnames(data)[colnames(data) ==  "Θήλεις"] <- "Females 0-14"
colnames(data)[colnames(data) == "...22"] <- "Females 15-24"
colnames(data)[colnames(data) == "...23"] <- "Females 25-39"
colnames(data)[colnames(data) == "...24"] <- "Females 40-54"
colnames(data)[colnames(data) == "...25"] <- "Females 55-64"
colnames(data)[colnames(data) == "...26"] <- "Females 65-79"
colnames(data)[colnames(data) == "...27"] <- "Females 80+"


# Print the column names to verify the change
print(colnames(data))

#Remove the first row
data = data[-1,]


data <- data %>%
  mutate_at(vars(contains("Sum"), contains("0-14"), contains("15-24"), contains("25-39"), contains("40-54"), contains("55-64"), contains("65-79"), contains("80+")), as.numeric)

str(data)
subset_data <- data %>%
  filter(grepl("ΔΗΜΟΣ", Municipality))


print(colnames(subset_data))


# Exclude the specified columns
excl_columns <- c("Municipality", "Geographical Code", "Males Sum", "Females Sum")
filter_data<- subset_data[, !colnames(subset_data) %in% excl_columns]



print(colnames(filter_data))

age_columns <- c("Both Genders 0-14", "Both Genders 15-24", "Both Genders 25-39", 
                 "Both Genders 40-54", "Both Genders 55-64", "Both Genders 65-79", "Both Genders 80+","Both Genders Sum")



# Subset the data, only take the both columns
clustering_data <- filter_data %>% select(all_of(age_columns))

sapply(clustering_data, class)
#write.csv(clustering_data, "C://Users//kosti//OneDrive//Desktop//Statistical Machine Learning//Project2//clustering_data.csv", row.names = FALSE)

#put the column Both Genders Sum in a variable
both_genders_sum <- clustering_data$`Both Genders Sum`



# Convert counts to frequencies by dividing each cell by the Both Genders Sum
clustering_data[-8] <- clustering_data[-8] / both_genders_sum
clustering_data <- clustering_data[,-8]
# Save the removed column 
removed_column <- clustering_data[, 7]

clustering_data <- clustering_data[,-7]



####------------------- Perform Hierarchical Clustering --------------------------

#---------------USING MAHALANOBIS -------------------------
#---------- Ward method-----------------------

#here we calculate the Mahalanobis Distance of our data
#in the mahal_dist there is the distance matrix
mahal_dist<- as.dist(apply(clustering_data, 1, function(i) mahalanobis(clustering_data, i, cov = cov(clustering_data))))

head(mahal_dist)

# Perform Hierarchical Clustering using Ward's method
hc_ward <- hclust(mahal_dist, method = "ward.D2")

# Plot the dendrogram of my hierarchical clustering
plot(hc_ward, ylab=NULL,main=NULL,xlab=NULL, cex=0.9)

#----------------USING COMPLETE LINKAGE -----------------------------

hc_complete <- hclust(mahal_dist, method = "complete")
summary(hc_complete)

# Plot the dendrogram
plot(hc_complete, main="Dendrogram for Hierarchical Clustering using Complete Linkage", xlab="Sample Index", sub="", cex=0.9)

# Plots the heights at which clusters are merged.
plot(hc_complete$height)


plot(hc_complete)
#Draws rectangles around the four clusters on the dendrogram.
rect.hclust(hc_complete,4)  ## puts a rectiangular arounf the groups





###--------------- run with other linkages------------------------

hc_single<-hclust(mahal_dist,method="single")
summary(hc_single)

# Plot the dendrogram
plot(hc_single, main="Dendrogram for Hierarchical Clustering using Single Linkage", xlab="Sample Index", sub="", cex=0.9)

#single is non-sense just noise here


hc_average<-hclust(mahal_dist,method="average")
summary(hc_average)
# Plot the dendrogram
plot(hc_average, main="Dendrogram for Hierarchical Clustering using Average Linkage", xlab="Sample Index", sub="", cex=0.9)


#------------- Calculate different distances ---------------------
# Euclidean Distance
dist_euclidean <- dist(clustering_data, method = "euclidean")

# Manhattan Distance
dist_manhattan <- dist(clustering_data, method = "manhattan")

# Gower Distance
dist_gower <- daisy(clustering_data, metric = "gower")

# Print distance matrices
print(dist_euclidean)
print(dist_manhattan)
print(dist_gower)




#numbers of clusters (k=2:6) and assigns cluster labels.
#cutree method gives me in which cluster each obs belongs
#### create clasifications
clas1<-cutree(hc_complete, k=2:6)
clas2<-cutree(hc_single, k=2:6)
clas3<-cutree(hc_average, k=2:6)


#-----------------------Silhouette Values -------------------------------



num_clusters <- 2:15
sil_list <- list()
sil_means <- numeric()

# Calculate silhouette values for different numbers of clusters
for (k in num_clusters) {
  clusters <- cutree(hc_ward, k = k)
  sil_values <- silhouette(clusters, mahal_dist)
  sil_list[[k]] <- sil_values
  sil_means <- c(sil_means, mean(sil_values[, 3]))
}

# Create a df with the siluette means of each number of cluster
sil_df <- data.frame(clusters = num_clusters, sil_means = sil_means)


# Plot the average silhouette widths df 
plot(sil_df$clusters, sil_df$sil_means, type = "b", pch = 19, frame = FALSE,
     xlab = "Clusters", ylab = "Average Silhouette Width", ylim =c(0,0.5),
     cex.lab = 1.3, cex.axis = 1.3)


# Plot the silhouette plot for 4 clusters

plot(sil_list[[4]], main = " ",
     col = 1:max(sil_list[[4]][, 1]), border = NA)


###----------------- wilks lambda ----------------------


#MANOVA (Multivariate Analysis of Variance) to assess the significance of clustering
#Wilks lambda is a test statistic used in MANOVA
# Cut the dendrogram into different numbers of clusters
wilks_values = numeric(length(num_clusters))

# iterate through the different number of clusters
for (i in 1:length(num_clusters)) {
  k = num_clusters[i]
  clusters = cutree(hc_ward, k)
  clustering_data_matrix = as.matrix(clustering_data)
  m = manova(clustering_data_matrix ~ as.factor(clusters))
  wilks_lambda = summary(m, test = "Wilks")$stats[1, 2]
  wilks_values[i] = wilks_lambda
}


wilks_df = data.frame(Clusters = num_clusters, WilksLambda = wilks_values)

# Plot Wilks' λ values
plot(wilks_df$Clusters, wilks_df$WilksLambda, type = "b", pch = 19, frame = FALSE,
     xlab = "Number of clusters",
     ylab = "Wilks' λ statistic",
     main = "",ylim =c(0,0.6),
     cex.lab = 1.3, cex.axis = 1.3)

#Wilks' λ for Different Numbers of Clusters

#---------Interpretation of the results of Hierarchical Clustering------------------

#--------------------AGE DISTRIBUTION IN EACH CLUSTER -------------------------------------

#put the claster label in the clustering_data as an extra column
class1<-cutree(hc_ward, k=4)
clusters_hier <- class1

# Add back the removed column to the dataset

clustering_data <- cbind(clustering_data, removed_column)

clustering_data$Cluster = class1
table(clustering_data$Cluster)
#as expected we see the same numbers with those in the silhouette plot for number of clusters=4



# Subset the data for Cluster 4 for example
cluster_number <- 4
cluster_data <- clustering_data[clustering_data$Cluster == cluster_number, ]

# Melt the data for plotting
cluster_melt <- melt(cluster_data, id.vars = "Cluster")

# Plot the demographic data, the aging distribution in cluster 4
ggplot(cluster_melt, aes(x = variable, y = value, fill = variable)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = sprintf("Age Distribution in Cluster %d", cluster_number), x = "Age Group", y = "Frequency") +
  theme_minimal()




#choose colors for each plot, there are 7 groups of ages, thats why there are 7 colors
#in each vector
# Define a consistent color palette for the age groups
# Define a consistent color palette for the age groups
color_palettes <- list(
  c("#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8"), 
  c("#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8"), 
  c("#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8"), 
  c("#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8", "#377EB8")
)

# Define the new labels for the age groups
age_group_labels <- c(
  "Both Genders 0-14" = "0-14", 
  "Both Genders 15-24" = "15-24", 
  "Both Genders 25-39" = "25-39", 
  "Both Genders 40-54" = "40-54", 
  "Both Genders 55-64" = "55-64", 
  "Both Genders 65-79" = "65-79", 
  "Both Genders 80+" = "80+"
)

# Create a list to store the plots
plots <- list()

# Loop through each cluster to plot the age distribution
for (cluster_number in 1:4) {
  # Take only the data of the current cluster
  cluster_data <- clustering_data[clustering_data$Cluster == cluster_number, ]
  
  # Melt the data for plotting
  cluster_melt <- melt(cluster_data, id.vars = "Cluster")
  
  # Rename the age group variable for better readability
  cluster_melt$variable <- factor(cluster_melt$variable, levels = names(age_group_labels), labels = age_group_labels)
  
  p <- ggplot(cluster_melt, aes(x = variable, y = value, fill = variable)) +
    geom_bar(stat = "identity", position = "dodge", show.legend = FALSE) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 20), 
          axis.text.y = element_text(size = 20),
          axis.title.x = element_text(size = 20),
          axis.title.y = element_text(size = 20),
          legend.position = "none") +
    labs(title = sprintf("Age Distribution in Cluster %d", cluster_number), x = "Age Group", y = "Frequency") +
    theme_minimal() +
    scale_fill_manual(values = color_palettes[[cluster_number]])
  
  # Store the plot in the list
  plots[[cluster_number]] <- p
}

# Arrange the plots in a 2x2 grid
grid.arrange(grobs = plots, ncol = 2, nrow = 2)


#-------------------------PRINCIPAL COMPONENT CALCULATION--------------------------------------------

pca_result <- prcomp(clustering_data, scale. = TRUE)
#PCA using Mahalanobis Distance and Ward - Hierarchical Clustering
# Visualize PCA with Mahalanobis distance clusters
fviz_pca_ind(pca_result, geom.ind = "point", col.ind = as.factor(class1), 
             title = "", palette = "jco", addEllipses = TRUE, 
             legend.title = "Clusters")



#------------------MODEL BASED CLUSTERING ------------------------------------------

pairs(clustering_data)
clustering_data <- clustering_data[,-8]

#Fits a Gaussian Mixture Model to the our data with the number of clusters
#(G) ranging from 2 to 6 and using different covariance structures (modelNames)

mc1<-Mclust(clustering_data, G=2:20, modelNames=c("EII", "VII", "EEI", "EVI", "VEI", "VVI"))
# These lines extract and display various attributes of
# the fitted model mc1, such as the number of components, 
# BIC values, log-likelihood, number of parameters, component means, 
# variances, posterior probabilities, and classifications


mc1$G#The optimal number of mixture components for our data is 18
mc1$BIC#All BIC values for all of the 18 mdoels.
mc1$bic#Optimal BIC value.
mc1$loglik#The loglikelihood corresponding to the optimal BIC.
mc1$df #The number of estimated parameters, here is 89.
mc1$parameters#A list with the following components:
mc1$pro #A vector whose kth component is the mixing proportion for the kth component 
mc1$mean #The mean for each component. 
mc1$variance  #A list of variance parameters for the model. 
mc1$z #posterior probabilities.
mc1$classification #map(z): The classification corresponding to z.
mc1$uncertainty#The uncertainty associated with the classification.
plot(mc1, what = "BIC", lwd = 2, pch = 19, cex = 1.5)

plot(mc1)
summary(mc1)

#lists all attributes of the mc1 object.
attributes(mc1)
# binds the posterior probabilities and uncertainties into a single matrix
#cbind(round(mc1$z,6), round(mc1$uncertainty,6))

#show the mixing proportions and the proportion of each cluster.
#ach value represents the proportion of the entire dataset that is assigned to each cluster
#for example in cluster 1 is the 26.75% of our dataset
mc1$parameters$pro



table(mc1$classification)/900
#proportion of data points assigned to each cluster based on the classifications


#----------------AGE DISTRIBUTION IN EACH CLUSTER-----------------------------

clusters_model_based= mc1$classification

clustering_data$Cluster = clusters_model_based

table(clustering_data$Cluster)

#take only the data of cluster 2
cluster2_data <- clustering_data[clustering_data$Cluster == 2, ]
# Melt the data
cluster2_melt <- melt(cluster2_data, id.vars = "Cluster")

#a list to store the plots
plot_list <- list()

age_group_labels <- c(
  "Both Genders 0-14" = "0-14", 
  "Both Genders 15-24" = "15-24", 
  "Both Genders 25-39" = "25-39", 
  "Both Genders 40-54" = "40-54", 
  "Both Genders 55-64" = "55-64", 
  "Both Genders 65-79" = "65-79", 
  "Both Genders 80+" = "80+"
)

color_palettes <- list(
  rep("#984EA3", 7), rep("#984EA3", 7), rep("#984EA3", 7),
  rep("#984EA3", 7), rep("#984EA3", 7), rep("#984EA3", 7),
  rep("#984EA3", 7), rep("#984EA3", 7), rep("#984EA3", 7),
  rep("#984EA3", 7), rep("#984EA3", 7), rep("#984EA3", 7),
  rep("#984EA3", 7), rep("#984EA3", 7), rep("#984EA3", 7),
  rep("#984EA3", 7), rep("#984EA3", 7), rep("#984EA3", 7)
)
# Loop through each cluster to create the plots
for (i in 1:18) {
  # The data of each cluster only
  cluster_data <- clustering_data[clustering_data$Cluster == i, ]
  cluster_melt <- melt(cluster_data, id.vars = "Cluster")
  
  # Rename the age group variable for better readability
  cluster_melt$variable <- factor(cluster_melt$variable, levels = names(age_group_labels), labels = age_group_labels)
  
  # Create the plot
  p <- ggplot(cluster_melt, aes(x = variable, y = value, fill = variable)) +
    geom_bar(stat = "identity") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), 
          axis.text.y = element_text(size = 8)) +
    labs(title = sprintf("Cluster %d", i), x = " ", y = " ") +
    theme_minimal() +
    scale_fill_manual(values = color_palettes[[i]]) +
    theme(legend.position = "none")  # Remove the legend
  
  # Save the plot in the list
  plot_list[[i]] <- p
}

# Arrange the plots in a 5x4 grid
grid.arrange(grobs = plot_list, ncol = 5, nrow = 4)

#-------------------------PRINCIPAL COMPONENT CALCULATION--------------------------------------------
#install.packages("factoextra")

pca_result <- prcomp(clustering_data, scale. = TRUE)

#COLORS
color_palette <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33", 
                   "#A6CEE3", "#FB9A99", "#1F78B4", "#33A02C", "#CAB2D6", "#6A3D9A",
                   "#B15928", "#FDBF6F", "#FFED6F", "#B2DF8A", "#A6CEE3", "#1F78B4")

#PCA plot
fviz_pca_ind(pca_result, geom.ind = "point", col.ind = as.factor(clusters_model_based), 
             title = "", palette = color_palette, addEllipses = TRUE, 
             legend.title = "Clusters") +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14),
    axis.title = element_text(size = 12),
    axis.text = element_text(size = 10),
    legend.position = "right",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10)
  )


#-----------------Adjusted Rand Index--------------------
clustering_data$Cluster_model_based <- clusters_model_based

#distribution of the model-based clusters
table(clustering_data$Cluster_model_based)

#hierarchical clustering labels
class1 <- cutree(hc_ward, k = 4)
clusters_hierarchical <- class1

clustering_data$Cluster_hierarchical <- clusters_hierarchical

table(clustering_data$Cluster_hierarchical)

#Calculate Adjusted Rand Index to compare the two clustering results
ari_value <- adjustedRandIndex(clustering_data$Cluster_model_based, clustering_data$Cluster_hierarchical)
print(paste("Adjusted Rand Index (ARI) between Model-Based and Hierarchical Clustering: ", ari_value))

#-----------------------------MULTINOMIAL MIXTURE MODELS-----------------

#-----------for further research ---------------------------------




