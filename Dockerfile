# stage1 as builder
FROM node:lts as builder

# copy the package.json to install dependencies
COPY package.json package-lock.json ./

ENV NODE_OPTIONS=--max_old_space_size=4096

# COPY ZscalerRootCertificate-2048-SHA256.crt /usr/share/ca-certificates/
# RUN npm config set cafile /usr/share/ca-certificates/ZscalerRootCertificate-2048-SHA256.crt
# Install the dependencies and make the folder
RUN npm install && mkdir /app && mv ./node_modules ./app

WORKDIR /app

COPY . .

# Build the project and copy the files
RUN npm run build

FROM nginx:alpine

#!/bin/sh
COPY nginx.conf /etc/nginx/nginx.conf

## Remove default nginx index page
RUN rm -rf /usr/share/nginx/html/*

# Copy from the stage 1
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 3000 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]
