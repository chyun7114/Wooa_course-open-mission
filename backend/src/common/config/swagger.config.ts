import { INestApplication } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

export class SwaggerConfig {
    static setUp(app: INestApplication) {
        const config = new DocumentBuilder()
            .setTitle('Moo-Server Version 1 API Document')
            .setDescription('서비스 이름은 뭘까요')
            .setVersion('1.0.0')
            .addBearerAuth()
            .build();

        const document = SwaggerModule.createDocument(app, config);
        SwaggerModule.setup('api-docs', app, document);
    }
}
