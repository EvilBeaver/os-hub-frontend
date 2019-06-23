FROM otymko/osweb:develop

ENV ASPNETCORE_ENVIRONMENT=Production
COPY src /app