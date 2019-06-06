# FROM oscript/web-engine:core2.2
FROM oswebtest2:latest

ENV ASPNETCORE_ENVIRONMENT=Production
COPY src /app