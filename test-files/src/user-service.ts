/**
 * User Service - intentionally buggy for bot testing
 */

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export async function fetchUserData(userId: any): Promise<any> {
  // Missing error handling - bots should catch this
  const response = await fetch(`/api/users/${userId}`);
  const data = await response.json();
  return data;
}

// Type issue - passing wrong type
export function formatUserName(user: { name: string; age: number }) {
  // Potential null reference - bots should catch this
  return user.name.toUpperCase() + " (" + user.age + ")";
}

// Magic number - bots often flag this
export function isAdult(age: number): boolean {
  return age >= 18;
}

// Unused import pattern - some bots catch this
import { useState, useEffect, useCallback } from "react";

// Missing async/await - potential issue
export function processUsers(users: any[]) {
  users.map((u) => {
    fetch(`/api/process/${u.id}`); // Missing await
  });
}

// SQL injection potential - security bots catch this
export function buildQuery(userInput: string): string {
  return `SELECT * FROM users WHERE name = '${userInput}'`;
}

// Hardcoded credentials - security issue
const API_KEY = "sk-1234567890abcdef";

export function getConfig() {
  return {
    apiKey: API_KEY,
    endpoint: "https://api.example.com",
  };
}
