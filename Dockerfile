# 基本となるASP.NETランタイムのイメージを使用
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base

# コンテナ内で作業するディレクトリを設定
WORKDIR /app

# アプリケーションのポート8080を公開
EXPOSE 8080

# .NET 8.0 SDKの公式イメージを使用
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# ソースコードのディレクトリを指定
WORKDIR /app

# 必要なプロジェクトファイル（csproj）をコピー
COPY ["CraftedGleam.Api/CraftedGleam.Api.csproj", "CraftedGleam.Api/"]

# 必要なパッケージを復元
RUN dotnet restore "CraftedGleam.Api/CraftedGleam.Api.csproj"

# 全てのソースコードをコンテナにコピー
COPY . .

# プロジェクトの作業ディレクトリに移動
WORKDIR "/app/CraftedGleam.Api"

# アプリケーションをリリース用にビルド
RUN dotnet build "CraftedGleam.Api.csproj" -c Release -o /app/build

# アプリケーションを公開
RUN dotnet publish "CraftedGleam.Api.csproj" -c Release -o /app/publish

# 最終的に公開されたファイルを基に実行するイメージを作成
FROM base AS final

# コンテナ内の作業ディレクトリを指定
WORKDIR /app

# ビルドと公開されたファイルをコピー
COPY --from=build /app/publish .

# アプリケーションを実行するためのエントリーポイントを設定
ENTRYPOINT ["dotnet", "CraftedGleam.Api.dll"]
