server {
    listen       8000;
    server_name  localhost;

    location / {
        root   /app;
    }
    
    location /basic_status {
        stub_status on;
        access_log off;
        allow all;
    #    deny all;
    }    
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}