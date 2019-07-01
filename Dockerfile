FROM evilbeaver/oscript-web:0.4.1

ENV ASPNETCORE_ENVIRONMENT=Production
COPY src /app