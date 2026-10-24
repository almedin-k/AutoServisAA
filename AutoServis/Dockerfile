FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy project files first so that "dotnet restore" is cached when only source code changes.
COPY AutoServis.Model/AutoServis.Model.csproj AutoServis.Model/
COPY AutoServis.Common.Services/AutoServis.Common.Services.csproj AutoServis.Common.Services/
COPY AutoServis.Services/AutoServis.Services.csproj AutoServis.Services/
COPY AutoServis.WebAPI/AutoServis.WebAPI.csproj AutoServis.WebAPI/
RUN dotnet restore AutoServis.WebAPI/AutoServis.WebAPI.csproj

COPY . .
RUN dotnet publish AutoServis.WebAPI/AutoServis.WebAPI.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "AutoServis.WebAPI.dll"]
