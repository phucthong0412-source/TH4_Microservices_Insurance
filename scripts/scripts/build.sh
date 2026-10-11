#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")/../.."
dotnet build ProductService.API
dotnet build PricingService.API
dotnet build PolicyService.API
dotnet build PaymentService.Api
dotnet build PolicySearchService.Api

dotnet build AgentPortalApiGateway/AgentPortalApiGateway
dotnet build AuthService
dotnet build ProductService
dotnet build PricingService
dotnet build PolicyService
dotnet build PaymentService
dotnet build PolicySearchService

dotnet build ProductService.Test
dotnet build PricingService.Test
dotnet build PolicyService.Test
dotnet build PaymentService.Test

dotnet test ProductService.Test
dotnet test PricingService.Test
dotnet test PolicyService.Test
dotnet test PaymentService.Test


dotnet build AuthService.Api

dotnet build ChatService.Api

dotnet build DashboardService.Api

dotnet build DocumentService.Api

dotnet build ChatService

dotnet build DashboardService

dotnet build DocumentService

dotnet build AuthService.Test

dotnet build ChatService.Test

dotnet build DashboardService.Test

dotnet build DocumentService.Test

dotnet build PolicySearchService.Test
dotnet test AuthService.Test
dotnet test ChatService.Test
dotnet test DashboardService.Test
dotnet test DocumentService.Test
dotnet test PolicySearchService.Test

dotnet build BlazorWasmClient/BlazorWasmClient
