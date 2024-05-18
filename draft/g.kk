import http

fun main() {
    println("Google Photos API client in Koka")
    
    // サンプルとして写真のリストを取得する要求を作成します
    val accessToken = "YOUR_ACCESS_TOKEN_HERE"
    
    // HTTPリクエスト作成
    val url = "https://photoslibrary.googleapis.com/v1/mediaItems"
    val response = http.get(url, headers: ["Authorization": "Bearer " ++ accessToken])
    
    println("Response Status: " ++ response.statusCode)
    println("Response Body: " ++ response.body)
}