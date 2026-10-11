# TH4_Microservices_Insurance
Bài thực hành số 4 - Microservices .NET Core

## Phạm vi Task #2

Solution `th1.sln` giữ đủ 29 project .NET: 9 nhóm service (implementation,
API, Test), AgentPortalApiGateway và BlazorWasmClient. DashboardService được
giữ nguyên. `Payment_Backup` giữ nguyên các bản project cũ và không được thêm
vào solution đang sử dụng.

Các implementation đang là template WeatherForecast của Task #1. Task #2
chuẩn bị project reference, MediatR, client, gateway, hạ tầng và CSDL;
chưa triển khai handler/controller nghiệp vụ bảo hiểm, đăng nhập, chat,
ghi dữ liệu hay đăng ký service với Eureka. Các test hiện có là test rỗng
của template, không phải bằng chứng kiểm thử nghiệp vụ.

## Source được cung cấp

| Thư mục thực tế | Vai trò |
| --- | --- |
| `AgentPortalApiGateway/AgentPortalApiGateway` | Ocelot, JWT, Eureka discovery, route tới các service |
| `BlazorWasmClient/BlazorWasmClient` | Client Blazor WebAssembly, dùng các contract API |
| `eureka-server/eureka-server` | Spring Boot Eureka registry, Gradle wrapper và Dockerfile Java 8 |
| `postgres/postgres` | PostgreSQL 11.4 Dockerfile và SQL tạo database |
| `scripts/scripts` | Script build/test, Compose infra/app, công cụ PostgreSQL portable và backup |
| `Web/Web` | Client Vue 2, cấu hình backend/Auth/Chat, Dockerfile và nginx |

Các contract còn thiếu của Product, Pricing, Policy, PolicySearch, Dashboard
được bổ sung vào project API hiện có từ repository gốc được liên kết trong
source client:
[asc-lab/dotnetcore-microservices-poc](https://github.com/asc-lab/dotnetcore-microservices-poc),
commit `6500daaf5ca6287385bfdfe5246cd1f3959c73fd`. Giữ các file `Class1.cs`
của người học và giấy phép Apache 2.0 trong `LICENSE`. Các project contract
dùng MediatR.Contracts 2.0.1; 9 implementation giữ MediatR 14.2.0 đã cài sẵn
và đăng ký bằng `builder.Services.AddMediatR(...)` trong `Program.cs`.

Tên project `.API` của Product/Policy/Pricing được giữ nguyên; namespace
contract gốc vẫn là `.Api`. DashboardService.Api dùng net8.0 để client Blazor
net8.0 có thể tham chiếu; implementation Dashboard vẫn net9.0.

## Build và kiểm tra

Máy đã có .NET SDK 9.0.101 và runtime .NET 8/9.

```powershell
dotnet restore th1.sln
dotnet build th1.sln
dotnet test th1.sln
```

Các script `scripts/scripts/build*.bat` và `build*.sh` đã sửa đường dẫn
cho cấu trúc giải nén hiện tại, bao gồm các nhóm service và Blazor.
Kết quả build cuối được lưu ở `scripts/scripts/build-result.log`.

Đã kiểm tra 9 service khởi động và trả 5 bản ghi tại `/weatherforecast`.
Profile `Task2` bổ sung vào launchSettings.json khớp cổng của source client
và Compose, giữ các profile gốc:

```powershell
dotnet run --project AuthService --launch-profile Task2
dotnet run --project BlazorWasmClient/BlazorWasmClient
```

## PostgreSQL và backup

Đã chạy PostgreSQL 11.4 portable tại `127.0.0.1:5432`, không cài Windows
service. Binary ở `%TEMP%/th1-postgresql11/pgsql/bin`; dữ liệu ở
`postgres/data` và không đưa vào Git. Cụm PostgreSQL này không tự chạy lại
sau khi khởi động Windows. Nếu thư mục tạm bị dọn, cung cấp binary PostgreSQL
11 qua tham số `-PgBin` của script.

Đã chạy chính file `postgres/postgres/createdatabases.sql`, tạo user
`lab_user` và 4 database:

- `lab_netmicro_payments`
- `lab_netmicro_jobs`
- `lab_netmicro_policy`
- `lab_netmicro_pricing`

Thông tin truy cập lab theo source giảng viên: `postgres` hoặc `lab_user`,
mật khẩu `lab_pass`. Database hiện chưa có bảng nghiệp vụ vì SQL Task #2
chỉ tạo database và cấp quyền.

```powershell
./scripts/scripts/postgres-local.ps1 -Action Status
./scripts/scripts/postgres-local.ps1 -Action Start
$env:PGPASSWORD='lab_pass'
./scripts/scripts/postgres-local.ps1 -Action Init
./scripts/scripts/backup-databases.ps1 -Mode Local
```

Script Init kiểm tra database đã tồn tại trước khi chạy SQL. Script backup
lấy danh sách database từ SQL, tạo archive custom bằng pg_dump và kiểm tra
catalog bằng pg_restore. 4 backup thực đã lưu trong `postgres/backups`
để nộp riêng; thư mục này không đưa vào Git.

Restore archive vào server đã có role `lab_user`, dùng binary PostgreSQL 11:

```powershell
& "$env:TEMP/th1-postgresql11/pgsql/bin/pg_restore.exe" `
  -h 127.0.0.1 -p 5432 -U postgres -d postgres --create `
  'PATH_TO_BACKUP.backup'
```

Lệnh restore này áp dụng khi database trong archive chưa tồn tại.

## Hạ tầng Docker

Đã cài Docker 29.3.1 và Compose v5.1.1. Cả `infra.yml` và `app.yml`
vượt qua `docker compose config --quiet`. Đường dẫn build đã sửa cho source
giải nén lồng một cấp. Giữ image PostgreSQL 11.4, Elasticsearch 8.9.2,
RabbitMQ 3-management và source Eureka của giảng viên. Các implementation
chưa có Dockerfile dùng chung `Dockerfile.service` để build đúng project
hiện có và runtime 8/9 tương ứng; giữ Dockerfile Gateway và Web được cung cấp.

Docker Desktop hiện không khởi động Engine được: lỗi tại socket
`dockerInference`, thông báo `The file cannot be accessed by the system`.
Chưa chạy thử container, RabbitMQ hoặc Elasticsearch. Không reset Docker,
không xóa volume và không cài phần mềm hệ thống để tránh ảnh hưởng dữ liệu.

Sau khi sửa Docker Desktop, dừng PostgreSQL portable trước để giải phóng
cổng 5432, rồi chạy:

```powershell
./scripts/scripts/postgres-local.ps1 -Action Stop
docker compose -f scripts/scripts/infra.yml up -d --build
docker compose -f scripts/scripts/infra.yml ps
```

Docker PostgreSQL dùng volume riêng, không dùng dữ liệu portable.
SQL được Docker entrypoint chạy khi volume mới được khởi tạo. Backup từ
container bằng `./scripts/scripts/backup-databases.ps1 -Mode Docker`.

`app.yml` chuẩn bị container cho 9 implementation, Gateway và Web. Các
container service vẫn chạy template; chưa thể thực hiện quy trình nghiệp vụ
qua Gateway cho tới khi triển khai phần nghiệp vụ của bài.

## Eureka và Web

Eureka đã restore/build bằng JDK 8 portable, tạo
`eureka-server/eureka-server/build/libs/eureka-server-0.0.1-SNAPSHOT.jar`,
và chạy thử trang quản trị HTTP 200. Gradle 6.8.2 của giảng viên không chạy
với Java 24 trên máy; JAVA_HOME toàn máy còn đang trỏ vào thư mục `bin`.
Dùng JDK 8 hoặc Dockerfile có sẵn, không nâng Gradle/Spring ngoài phạm vi bài.

```powershell
$env:JAVA_HOME='PATH_TO_JDK8_ROOT'
cd eureka-server/eureka-server
./gradlew.bat build --no-daemon
./gradlew.bat bootRun
```

Web đã restore và build production bằng Node 24.13.0, thay node-sass cũ
bằng Dart Sass 1.77.8 và sass-loader 7.3.1 để không yêu cầu Python 2.
Giữ Vue 2 và giao diện giảng viên. Sử dụng package-lock.json làm lockfile
hiện hành; yarn.lock gốc được giữ để đối chiếu. Build còn 2 cảnh báo kích
thước bundle và thông báo Browserslist cũ.

```powershell
cd Web/Web
npm ci --legacy-peer-deps
$env:NODE_OPTIONS='--openssl-legacy-provider'
npm run build
```

Gateway đã nâng Steeltoe.Discovery.Eureka lên bản vá 3.4.0 cùng nhánh 3.x.
Một số dependency bắc cầu cũ ở test/Blazor và dependency Vue 2 vẫn xuất hiện
trong kết quả audit riêng; việc build không có cảnh báo không thay thế audit.
