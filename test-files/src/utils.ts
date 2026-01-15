/**
 * Utility functions - with style issues
 */

// Inconsistent naming conventions
export const getUserName = (u: any) => u.name;
export const get_user_age = (u: any) => u.age;
export const GetUserEmail = (u: any) => u.email;

// Overly complex condition
export function isValidUser(user: any): boolean {
  return (
    user &&
    user.name &&
    user.name.length > 0 &&
    user.email &&
    user.email.includes("@") &&
    user.age &&
    user.age >= 0 &&
    user.age <= 150 &&
    (!user.phone || (user.phone.length >= 10 && user.phone.length <= 15))
  );
}

// No JSDoc comments on public API
export function formatCurrency(amount: number, currency: string): string {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
  }).format(amount);
}

// Regex without comments - hard to understand
export function extractEmails(text: string): string[] {
  const regex =
    /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g;
  return text.match(regex) || [];
}

// Array mutation in map
export function processItems(items: any[]): any[] {
  return items.map((item, index) => {
    item.processed = true; // Mutating input!
    item.index = index;
    return item;
  });
}

// Date handling without timezone consideration
export function formatDate(date: Date): string {
  return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
}

// Promise.all without error handling for individual items
export async function fetchAll(urls: string[]): Promise<any[]> {
  return Promise.all(urls.map((url) => fetch(url).then((r) => r.json())));
}
