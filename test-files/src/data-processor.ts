/**
 * Data Processor - more intentional issues
 */

interface DataItem {
  id: string;
  value: number;
  metadata?: Record<string, unknown>;
}

// Complex function with multiple issues
export async function processDataBatch(items: DataItem[]): Promise<void> {
  // No input validation
  for (let i = 0; i < items.length; i++) {
    const item = items[i];

    // Synchronous delay - should use proper async
    const start = Date.now();
    while (Date.now() - start < 100) {
      // Busy wait - terrible pattern
    }

    // Type coercion issue
    if (item.value == "0") {
      console.log("Zero value detected");
    }

    // Potential memory leak - creating closures in loop
    setTimeout(() => {
      console.log(item.id);
    }, 1000);
  }
}

// Function with too many parameters - code smell
export function createReport(
  title: string,
  author: string,
  date: Date,
  items: DataItem[],
  format: string,
  includeMetadata: boolean,
  sortOrder: "asc" | "desc",
  limit: number,
  offset: number,
  filters: Record<string, string>
): string {
  // Implementation...
  return JSON.stringify({ title, items: items.slice(offset, offset + limit) });
}

// Empty catch block - bad error handling
export async function riskyOperation(): Promise<void> {
  try {
    await fetch("/api/risky");
  } catch (e) {
    // Silently swallow error - bots should flag this
  }
}

// Duplicate code pattern
export function calculateTaxA(amount: number): number {
  const rate = 0.18;
  const base = amount * rate;
  const surcharge = base * 0.1;
  return base + surcharge;
}

export function calculateTaxB(amount: number): number {
  const rate = 0.18;
  const base = amount * rate;
  const surcharge = base * 0.1;
  return base + surcharge;
}

// Inconsistent return types
export function getValue(key: string) {
  if (key === "special") {
    return 42;
  }
  if (key === "none") {
    return null;
  }
  return "default";
}

// Console.log left in code
export function debugFunction(data: unknown): void {
  console.log("DEBUG:", data);
  console.log("Timestamp:", new Date().toISOString());
}
