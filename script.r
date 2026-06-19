library(e1071)
table=read.table('C:\\Users\\aflac\\Documents\\GitHub\\html-Rpg\\kolachalama_data.csv',sep=',',header=TRUE)
attach(table)
Category <- sample(c(0, 1), 50, replace = TRUE) # random vector not attached to table, factor issue
table[["Category"]] <- Category # add category with random labels
table=table[,c("ph","Hb","LDL","HDL","Category")]

### Table for model 1
table.1=table[,c("ph","Hb","Category")] # 
X <- subset(table.1, select = -Category)
y <- Category
model <- svm(X, y) # same as print(model) or summary(model) 
# unavailable: plot(model,X)
pred<-predict(model,X)
pred_table=table(pred, y) #
#cat(capture.output(pred_table),"\n,", file="/cloud/project/out/out_2.file",sep=",", header=FALSE,append =TRUE,labels=NULL)
write.table(as.data.frame(pred_table), "C:\\Users\\aflac\\Documents\\GitHub\\html-Rpg\\out_2.file", row.names = FALSE,col.names=FALSE,append=TRUE,sep=',')

# Table for model 2
table.2=table[,c("LDL","HDL","Category")]
X <- subset(table.2, select = -Category)
y <- Category
model <- svm(X, y) # same as print(model) or summary(model) 
# unavailable: plot(model,X)
pred<-predict(model,X)
pred_table=table(pred, y) #
write.table(as.data.frame(pred_table), "C:\\Users\\aflac\\Documents\\GitHub\\html-Rpg\\out_2.file", row.names = FALSE,col.names=FALSE,append=TRUE,sep=',')

###########################################
library(dygraphs)
library(widgetframe)
library(htmlwidgets)
### Example
# Create a time-series widget with dygraph
#ts_widget <- dygraph(nhtemp, main = "New Haven Temperatures") # toggle or cursor feature of dygraph
# Save it specifically formatted for responsive iframes
#saveWidget(frameableWidget(ts_widget), file = "embedded_chart.html", selfcontained = TRUE)
# Once exported, copy embedded_chart.html into your web server directory and call it from your primary HTML source file like this:
#<iframe src="embedded_chart.html" width="100%" height="400px" style="border:none;"></iframe>
  
###########################################
library(DT)

### Create an interactive html table of 2 models
table=read.table('C:\\Users\\aflac\\Documents\\GitHub\\html-Rpg\\out_2.file',sep=",",header=FALSE)
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

# Create your interactive data table widget
# 3. Render the  table
my_interactive_table <-datatable(
  freq_table,
  colnames = c("Value Interval", "Frequency (Count)", "Percentage (%)", "Cumulative Count"),
  options = list(pageLength = 10, dom = 'ftp', searching = TRUE), # or not searching = TRUE
  caption = 'Table 1: Binned Frequency Distribution for Continuous Feature.'
)

# Export to a standalone HTML file in your current working directory
saveWidget(my_interactive_table, "C:\\Users\\aflac\\Documents\\GitHub\\html-Rpg\\feature_frequency_table.html", selfcontained = TRUE) # ref src
#<iframe src="C:/Users/aflac/Downloads/feature_frequency_table.html" width="100%" height="400px" style="border:none;"></iframe>

# OR a density graph
#
data=table$V1
hist(table$V1)

# Calculate statistics
mean_val <- mean(data, na.rm = TRUE)
median_val <- median(data, na.rm = TRUE)
q25      <- quantile(data_vec, 0.25, na.rm = TRUE)
q75      <- quantile(data_vec, 0.75, na.rm = TRUE)

# Create histogram
hist(data,
     main = "Histogram with Mean and Median Lines",
     xlab = "Values",
     col = "lightblue",
     border = "white")

# Add mean line (red, dashed)
abline(v = mean_val, col = "red", lwd = 2, lty = 2)
# Add median line (blue, solid)
abline(v = median_val, col = "blue", lwd = 2, lty = 1)
abline(v=q25,col="green",lwd=2,lty=1) # FIX
abline(v=q75,col="yellow",lwd=2,lty=2) # FIX

# Add legend
legend("topright",
       legend = c(paste0("Mean = ", round(mean_val, 2)), # ADD
                  paste0("Median = ", round(median_val, 2))), #ADD
       col = c("red", "blue"),
       lty = c(2, 1),
       lwd = 2,
       bty = "n")
# Base R alternative to hist()
# See if it can be made interactive with toggle cursor
plot(density(table$V1),main="Density Plot",col="blue",lwd=2)
polygon(density(table$V1),col="lightblue",border="blue")
