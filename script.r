library(e1071)
table=read.table('/cloud/project/kolachalama_data.csv',sep=',',header=TRUE)
attach(table)
Category <- sample(c(0, 1), 50, replace = TRUE) # random vector not attached to table, factor issue
table[["Category"]] <- Category # add category with random labels
table=table[,c("ph","Hb","LDL","HDL","Category")]


table.1=table[,c("ph","Hb","Category")] # 
X <- subset(table.1, select = -Category)
y <- Category
model <- svm(X, y) # same as print(model) or summary(model) 
# unavailable: plot(model,X)
pred<-predict(model,X)
pred_table=table(pred, y) #
#cat(capture.output(pred_table),"\n,", file="/cloud/project/out/out_2.file",sep=",", header=FALSE,append =TRUE,labels=NULL)
write.table(as.data.frame(pred_table), "/cloud/project/out/out_2.file", row.names = FALSE,col.names=FALSE,append=TRUE,sep=',')

table.2=table[,c("LDL","HDL","Category")]
X <- subset(table.2, select = -Category)
y <- Category
model <- svm(X, y) # same as print(model) or summary(model) 
# unavailable: plot(model,X)
pred<-predict(model,X)
pred_table=table(pred, y) #
write.table(as.data.frame(pred_table), "/cloud/project/out/out_2.file", row.names = FALSE,col.names=FALSE,append=TRUE,sep=',')

###########################################
library(dygraphs)
library(widgetframe)
library(htmlwidgets)

# Create a time-series widget with dygraph
ts_widget <- dygraph(nhtemp, main = "New Haven Temperatures")

# Save it specifically formatted for responsive iframes
saveWidget(frameableWidget(ts_widget), file = "embedded_chart.html", selfcontained = TRUE)

# Once exported, copy embedded_chart.html into your web server directory and call it from your primary HTML source file like this:
#<iframe src="embedded_chart.html" width="100%" height="400px" style="border:none;"></iframe>
  
###########################################
library(DT)
library(htmlwidgets)

table=read.table('/cloud/project/out/out_2.file',sep=",",header=FALSE)
# Set parameters for the feature
data_vec <- table$V1#example: iris$Sepal.Length
bin_w <- 0.2                     # Choose a meaningful bin width for your data
n_obs <- length(data_vec)

# 2. Continuous Frequency Table Generation
# Create break intervals matching the scale of your variable
breaks <- seq(floor(min(data_vec)), ceiling(max(data_vec)), by = bin_w)

# Cut the continuous data into intervals
intervals <- cut(data_vec, breaks = breaks, right = FALSE)

# Generate the frequency, relative frequency, and cumulative table
freq_table <- data.frame(table(Interval = intervals))
freq_table$Percentage <- round((freq_table$Freq / n_obs) * 100, 2)
freq_table$Cumulative_Freq <- cumsum(freq_table$Freq)

# View the formatted summary table OR
print(freq_table)
#OR
# 3. Render the  table
my_interactive_table <-datatable(
  freq_table,
  colnames = c("Value Interval", "Frequency (Count)", "Percentage (%)", "Cumulative Count"),
  options = list(pageLength = 10, dom = 'ftp', searching = TRUE),
  caption = 'Table 1: Binned Frequency Distribution for Continuous Feature.'
)
### 
hist(table$V1)
# Base R alternative to hist()
plot(density(table$V1),main="Density Plot",col="blue",lwd=2)
polygon(density(table$V1),col="lightblue",border="blue")

# Create your interactive data table widget
my_interactive_table <- datatable(
  freq_table,
  colnames = c("Value Interval", "Frequency (Count)", "Percentage (%)", "Cumulative Count"),
  options = list(pageLength = 10, dom = 'ftp')
) # just caption excluded includes search bar

# Export to a standalone HTML file in your current working directory
saveWidget(my_interactive_table, "/cloud/project/feature_frequency_table.html", selfcontained = TRUE) # ref src

########################################## review
library(ggplot2)

# Create a sample continuous vector containing missing values
data_vec <- iris$Sepal.Length
data_vec[c(5, 10, 15, 20)] <- NA  # Inject 4 missing values manually for testing

# 1. Count missing observations dynamically
n_missing <- sum(is.na(data_vec))
clean_vec <- na.omit(data_vec)  # Strips NAs cleanly for calculations

# 2. Compute summary statistics using na.rm = TRUE
mean_val <- mean(data_vec, na.rm = TRUE)
med_val  <- median(data_vec, na.rm = TRUE)
q25      <- quantile(data_vec, 0.25, na.rm = TRUE)
q75      <- quantile(data_vec, 0.75, na.rm = TRUE)

bin_w    <- 0.2
n_obs    <- length(clean_vec) # Base counts on the present non-missing data

# 3. Plot with a dynamic subtitle warning about the NAs
ggplot(data.frame(x = clean_vec), aes(x = x)) +
  geom_histogram(binwidth = bin_w, fill = "gray95", color = "gray75") +
  geom_density(aes(y = after_stat(density) * n_obs * bin_w), color = "gray40", linewidth = 1) +
  geom_vline(xintercept = c(q25, q75), color = "purple", linetype = "dotted", linewidth = 0.8) +
  geom_vline(aes(xintercept = med_val, color = "Median"), linetype = "dashed", linewidth = 1.1) +
  geom_vline(aes(xintercept = mean_val, color = "Mean"), linetype = "solid", linewidth = 1.1) +
  scale_color_manual(name = "Statistics", values = c("Mean" = "firebrick", "Median" = "dodgerblue")) +
  labs(
    title = "Continuous Feature Distribution",
    subtitle = paste("Missing Data Note:", n_missing, "blank records (NAs) were safely excluded from this plot."),
    x = "Feature Values",
    y = "Frequency"
  ) +
  theme_minimal() +
  theme(legend.position = "top")

library(widgetframe)
library(widgetframe)
library(plotly)

# Create your plot
p <- plot_ly(iris, x = ~Sepal.Length, y = ~Petal.Length, type = "scatter", mode = "markers")

# Save inside a responsive pym.js iframe structure
frameWidget(p, file = "responsive_plot.html") # N/A

library(plotly)
library(htmlwidgets)

# 1. Create an interactive histogram for a single continuous feature
fig <- plot_ly(
  x = ~iris$Sepal.Length, 
  type = "histogram",
  marker = list(color = "#3498db", line = list(color = "#ffffff", width = 1))
) %>% 
  layout(
    title = "Distribution of Sepal Length",
    xaxis = list(title = "Continuous Value Metric"),
    yaxis = list(title = "Frequency")
  )

# 2. Export to a self-contained, standalone HTML file
saveWidget(fig, file = "/cloud/project/distribution_plot.html", selfcontained = TRUE) # 


