FROM nginx:latest

COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 8000
USER 1001

WORKDIR /app

CMD ["nginx", "-g", "daemon off;"]