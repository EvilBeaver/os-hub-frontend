FROM evilbeaver/oscript-web:dev

ENV ASPNETCORE_ENVIRONMENT=Production
COPY src /app