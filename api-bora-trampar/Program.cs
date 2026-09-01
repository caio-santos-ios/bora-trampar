using System.ComponentModel.DataAnnotations;
using api_bora_trampar.src.Configuration;
using DotNetEnv;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;

WebApplicationBuilder builder = WebApplication.CreateBuilder(args);

Env.Load();

builder.Services.AddEndpointsApiExplorer();
builder.AddBuilderConfiguration();
builder.AddContext();
builder.AddBuilderServices();

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme    = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    string secretKey = Environment.GetEnvironmentVariable("SECRET_KEY") ?? "";
    string issuer    = Environment.GetEnvironmentVariable("ISSUER")     ?? "";
    string audience  = Environment.GetEnvironmentVariable("AUDIENCE")   ?? "";

    options.TokenValidationParameters = new Microsoft.IdentityModel.Tokens.TokenValidationParameters
    {
        ValidateIssuer           = true,
        ValidateAudience         = true,
        ValidateLifetime         = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer              = issuer,
        ValidAudience            = audience,
        ClockSkew                = TimeSpan.FromMinutes(5),
        IssuerSigningKey         = new Microsoft.IdentityModel.Tokens.SymmetricSecurityKey(
            System.Text.Encoding.UTF8.GetBytes(secretKey)
        )
    };

    // options.Events = new JwtBearerEvents
    // {
    //     OnMessageReceived = context =>
    //     {
    //         var accessToken = context.Request.Query["access_token"];
    //         var path        = context.HttpContext.Request.Path;

    //         if (!string.IsNullOrEmpty(accessToken) &&
    //             (path.StartsWithSegments("/hubs/notifications") ||
    //              path.StartsWithSegments("/hubs/chat")))
    //         {
    //             context.Token = accessToken;
    //         }

    //         return Task.CompletedTask;
    //     }
    // };
});

// Registra o filtro como Scoped (necessário para injeção de dependência)
// builder.Services.AddScoped<LoggerActionFilter>();

builder.Services.AddControllers(options =>
{
    // options.Filters.Add<LoggerActionFilter>();
})
.ConfigureApiBehaviorOptions(options =>
{
    options.InvalidModelStateResponseFactory = context =>
    {
        var errors = context.ModelState
            .Where(e => e.Value!.Errors.Count > 0)
            .Select(e => new {
                Field   = e.Key,
                Message = e.Value!.Errors.First().ErrorMessage,
                Order   = context.ActionDescriptor.Parameters
                    .SelectMany(p => p.ParameterType.GetProperties())
                    .FirstOrDefault(p => p.Name == e.Key)?
                    .GetCustomAttributes(typeof(DisplayAttribute), false)
                    .Cast<DisplayAttribute>()
                    .FirstOrDefault()?.Order ?? 999
            })
            .OrderBy(e => e.Order)
            .Select(e => new { e.Field, e.Message })
            .ToList();

        return new BadRequestObjectResult(new { errors });
    };
});

// builder.Services.AddSwaggerGen(c =>
// {
//     c.CustomSchemaIds(type => type.FullName);

//     c.AddSecurityDefinition("Bearer", new Microsoft.OpenApi.Models.OpenApiSecurityScheme
//     {
//         Name         = "Authorization",
//         Type         = Microsoft.OpenApi.Models.SecuritySchemeType.ApiKey,
//         In           = Microsoft.OpenApi.Models.ParameterLocation.Header,
//         Scheme       = "Bearer",
//         BearerFormat = "JWT",
//         Description  = "JWT Authorization header using the Bearer scheme. Example: 'Bearer {token}'"
//     });

//     c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement
//     {
//         {
//             new Microsoft.OpenApi.Models.OpenApiSecurityScheme
//             {
//                 Reference = new Microsoft.OpenApi.Models.OpenApiReference
//                 {
//                     Type = Microsoft.OpenApi.Models.ReferenceType.SecurityScheme,
//                     Id   = "Bearer"
//                 }
//             },
//             Array.Empty<string>()
//         }
//     });
// });

string[] allowedOrigins = (Environment.GetEnvironmentVariable("ALLOWED_ORIGINS") ?? "http://localhost:3000").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AppPolicy", policy =>
        policy
            .WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials());
});

builder.Services.AddAuthorization();

var app = builder.Build();

// if (app.Environment.IsDevelopment())
// {
//     app.UseSwagger();
//     app.UseSwaggerUI();
// }

app.UseHttpsRedirection();

app.UseCors("AppPolicy");

var uploadPath = Path.Combine(builder.Environment.ContentRootPath, "wwwroot", "uploads");
if (!Directory.Exists(uploadPath)) Directory.CreateDirectory(uploadPath);

app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.Run();