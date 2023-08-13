#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:7.0 AS build
ARG TARGETARCH
WORKDIR /src
COPY ["Test.WeatherForecast.API/Test.WeatherForecast.API.csproj", "Test.WeatherForecast.API/"]
RUN dotnet restore -a $TARGETARCH "Test.WeatherForecast.API/Test.WeatherForecast.API.csproj"
COPY . .
WORKDIR "/src/Test.WeatherForecast.API"
RUN dotnet build -a $TARGETARCH "Test.WeatherForecast.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -a $TARGETARCH "Test.WeatherForecast.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Test.WeatherForecast.API.dll"]