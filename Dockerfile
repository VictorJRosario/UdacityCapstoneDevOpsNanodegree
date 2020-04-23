## Step 1
# Choose Image
FROM nginx

## Step 2
# Remove
RUN rm /usr/share/nginx/html/index.html

## Step 3
# Copy File
COPY index.html /usr/share/nginx/html

