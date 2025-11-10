import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';
import { SwaggerConfig } from './common/config/swagger.config';
import { ResponseInterceptor } from './common/interceptors';

async function bootstrap() {
    const app = await NestFactory.create(AppModule);

    const configService = app.get(ConfigService);
    const port = configService.get<number>('PORT', 3000);

    app.useGlobalInterceptors(new ResponseInterceptor());

    app.useGlobalPipes(
        new ValidationPipe({
            whitelist: true,
            forbidNonWhitelisted: true,
            transform: true,
        }),
    );

    // CORS 설정 (필요한 경우)
    app.enableCors({
        origin: true,
        credentials: true,
    });

    SwaggerConfig.setUp(app);
    await app.listen(port);
}

void bootstrap();
