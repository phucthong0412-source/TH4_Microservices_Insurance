FROM node:24-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --legacy-peer-deps --no-audit --no-fund

COPY . .
ENV VUE_APP_CHAT_URL=http://localhost:4099
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN npm run build

FROM nginx:stable-perl
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
