import { defineConfig } from 'vite';
import glsl from 'vite-plugin-glsl';

export default defineConfig({
  base: '/SilkSpun/', // Replace with your repository name (include leading/trailing slash)
  plugins: [glsl()],
});