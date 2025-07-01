// src/main.ts

import Stats from 'stats-js';

import { GameWorld } from './core/GameWorld';
import { TestScene } from './scenes/TestScene';
import { FluidScene } from './scenes/FluidScene';
import { RenderingPipeline } from './rendering/RenderingPipeline';


async function main() {
    // 📊 Setup Stats (FPS Counter)
    const stats = new Stats();
    document.body.appendChild(stats.dom);


    // const sceneScale: number = 176;
    // const sceneWidth: number = (sceneScale * window.innerWidth) / window.innerHeight;
    // const sceneHeight: number = sceneScale;
    const sceneWidth = 320;
    const sceneHeight = 176;

    const gameWorld = new GameWorld()
    gameWorld.loadScene(new TestScene());

    const renderingPipeline = new RenderingPipeline(sceneWidth, sceneHeight);
    console.log(gameWorld.getAllEntities());
    renderingPipeline.addEntities(gameWorld.getAllEntities());

    let lastTime = performance.now(); // 👈 Track previous timestamp

    // function gameLoop(currentTime: number) {
    //     stats.begin();

    //     const deltaTime = (currentTime - lastTime) / 1000; // 👈 Convert ms to seconds
    //     lastTime = currentTime;

    //     gameWorld.update(deltaTime);
    //     gameWorld.syncMeshState();
    //     renderingPipeline.render();

    //     stats.end();
    //     requestAnimationFrame(gameLoop);
    // }

    // const targetFPS = 0.5;
    const targetFPS = 10000;
    const minFrameTime = 1000 / targetFPS; // In ms

    function gameLoop(currentTime: number) {
        requestAnimationFrame(gameLoop);

        const deltaTime = currentTime - lastTime;

        if (deltaTime < minFrameTime) return; // ❌ Too soon, skip this frame

        lastTime = currentTime;

        stats.begin();

        gameWorld.update(deltaTime / 1000); // In seconds
        gameWorld.syncMeshState();
        renderingPipeline.render();

        stats.end();
    }

    requestAnimationFrame(gameLoop);
}

// 🚀 Start the Game
main();

