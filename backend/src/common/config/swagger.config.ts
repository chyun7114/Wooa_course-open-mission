import { INestApplication } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

export class SwaggerConfig {
    static setUp(app: INestApplication) {
        const config = new DocumentBuilder()
            .setTitle('Tetris-Server API Document')
            .setDescription('테트리스 서버 API 문서입니다.')
            .setVersion('1.0.0')
            .addBearerAuth()
            .build();

        const document = SwaggerModule.createDocument(app, config);
        SwaggerModule.setup('api-docs', app, document);
    }
}
