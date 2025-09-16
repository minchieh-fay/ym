<template>
  <view class="container">
    <view class="header">
      <text class="title">欢迎使用YM小程序</text>
    </view>
    <view class="content">
      <text class="description">这是一个基于UniApp开发的小程序项目</text>
    </view>
  </view>
</template>

<script setup lang="ts">
// 页面逻辑
</script>

<style scoped>
.container {
  padding: 20px;
  min-height: 100vh;
  background-color: #f5f5f5;
}

.header {
  text-align: center;
  margin-bottom: 40px;
}

.title {
  font-size: 24px;
  font-weight: bold;
  color: #333;
}

.content {
  text-align: center;
}

.description {
  font-size: 16px;
  color: #666;
  line-height: 1.5;
}
</style>
