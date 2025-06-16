// src/main.ts

import Stats from 'stats-js';

import { GameWorld } from './core/GameWorld';
import { TestScene } from './scenes/TestScene';
import { RenderingPipeline } from './rendering/RenderingPipeline';


async function main() {
    // 📊 Setup Stats (FPS Counter)
    const stats = new Stats();
    document.body.appendChild(stats.dom);


    const sceneScale: number = 176;
    const sceneWidth: number = (sceneScale * window.innerWidth) / window.innerHeight;
    const sceneHeight: number = sceneScale;

    const gameWorld = new GameWorld()
    gameWorld.loadScene(new TestScene());

    const renderingPipeline = new RenderingPipeline(sceneWidth, sceneHeight);
    renderingPipeline.addEntities(gameWorld.getAllEntities());


    function gameLoop(time: number) {
        stats.begin();

        renderingPipeline.render();

        stats.end();
        requestAnimationFrame(gameLoop);
    }

    requestAnimationFrame(gameLoop);
}

// 🚀 Start the Game
main();
